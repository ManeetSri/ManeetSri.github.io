// Rate limiting algorithms side by side, for ```visual rateLimiter.
// Props: { algorithm, requests: [times in seconds, or { at, count } for a burst] } plus, by algorithm:
//   token-bucket: capacity, refillPerSecond (starts full; each request takes a token)
//   leaky-bucket: capacity, leakPerSecond (a queue: each accepted request leaves 1/leak seconds after the one
//     before it, so output is smooth; a full queue rejects)
//   fixed-window, sliding-log, sliding-counter: window (seconds), limit
// Fixed windows are [k·window, (k+1)·window). The sliding log keeps the times of allowed requests in the last
// `window` seconds. The sliding counter estimates that count as previous × (share of the previous window still
// inside) + current. Rejected requests never count.
// Each frame: { results, current, time, state, allowed, rejected, message }; `results` has every request with
// `allowed` true, false or null (still to come), and `leaves` for the leaky bucket.
import { checkNumber, checkTitle, isNumber, isObject, num, pct, plural, quote, secs, unknownField } from './common.js';

export const RATE_ALGORITHMS = ['token-bucket', 'leaky-bucket', 'fixed-window', 'sliding-log', 'sliding-counter'];
export const ALGORITHM_NAMES = { 'token-bucket': 'Token bucket', 'leaky-bucket': 'Leaky bucket', 'fixed-window': 'Fixed window', 'sliding-log': 'Sliding log', 'sliding-counter': 'Sliding window counter' };
const SETTINGS = {
    'token-bucket': ['capacity', 'refillPerSecond'],
    'leaky-bucket': ['capacity', 'leakPerSecond'],
    'fixed-window': ['window', 'limit'],
    'sliding-log': ['window', 'limit'],
    'sliding-counter': ['window', 'limit'],
};
const ALL_SETTINGS = ['capacity', 'refillPerSecond', 'leakPerSecond', 'window', 'limit'];
const MAX_REQUESTS = 200;
const MAX_SIZE = 100;
const EPS = 1e-9;

// Request times, with bursts expanded
export const expandRequests = (requests) => requests.flatMap((request) => (isObject(request) ? Array(request.count ?? 1).fill(request.at) : [request]));

const checkRequests = (requests) => {
    if (!Array.isArray(requests) || requests.length === 0) return '`requests` must be a list of times in seconds, such as [0, 0.1, 0.2, { at: 1, count: 5 }]';
    for (const [index, request] of requests.entries()) {
        const where = `requests[${index}]`;
        if (isObject(request)) {
            const issue = unknownField(request, ['at', 'count'], `${where}: `)
                ?? (isNumber(request.at) && request.at >= 0 ? null : `${where}: \`at\` must be a time in seconds, 0 or later, not ${quote(request.at)}`)
                ?? (request.count === undefined || (Number.isInteger(request.count) && request.count >= 1) ? null : `${where}: \`count\` must be a whole number of at least 1, not ${quote(request.count)}`);
            if (issue) return issue;
        } else if (!isNumber(request) || request < 0) {
            return `${where} must be a time in seconds (0 or later) or { at, count }, not ${quote(request)}`;
        }
    }
    const times = expandRequests(requests);
    if (times.length > MAX_REQUESTS) return `there are ${times.length} requests; keep it to ${MAX_REQUESTS} or fewer`;
    const back = requests.findIndex((request, index) => index > 0 && (isObject(request) ? request.at : request) < (isObject(requests[index - 1]) ? requests[index - 1].at : requests[index - 1]));
    if (back > 0) return `requests must be in time order: requests[${back}] comes before the one listed above it`;
    return null;
};

export const rateLimiterSchema = (props) => {
    if (!isObject(props)) return 'expected settings with `algorithm` and `requests`';
    const problem = unknownField(props, ['title', 'algorithm', 'requests', ...ALL_SETTINGS]) ?? checkTitle(props);
    if (problem) return problem;
    const { algorithm } = props;
    if (algorithm === undefined) return `\`algorithm\` is missing: use ${RATE_ALGORITHMS.join(', ')}`;
    if (!RATE_ALGORITHMS.includes(algorithm)) return `unknown \`algorithm\` ${quote(algorithm)}: use ${RATE_ALGORITHMS.join(', ')}`;
    const wanted = SETTINGS[algorithm];
    const stray = ALL_SETTINGS.find((name) => props[name] !== undefined && !wanted.includes(name));
    if (stray) return `${algorithm} doesn't use \`${stray}\`; it takes ${wanted.map((name) => `\`${name}\``).join(' and ')}`;
    const issue = algorithm === 'token-bucket' || algorithm === 'leaky-bucket'
        ? checkNumber(props.capacity, 'capacity', { whole: true, min: 1, max: MAX_SIZE }) ?? checkNumber(props[wanted[1]], wanted[1], { above: 0 })
        : checkNumber(props.window, 'window', { above: 0 }) ?? checkNumber(props.limit, 'limit', { whole: true, min: 1, max: MAX_SIZE });
    return issue ?? checkRequests(props.requests) ?? true;
};

// The most items of `times` (sorted) inside any half-open span [t, t + length): { count, from, to }
export const busiestSpan = (times, length) => {
    let best = { count: 0, from: 0, to: 0 };
    let end = 0;
    times.forEach((from, start) => {
        while (end < times.length && times[end] < from + length - EPS) end += 1;
        if (end - start > best.count) best = { count: end - start, from, to: times[end - 1] };
    });
    return best;
};

const windowLabel = (index, size) => `${num(index * size)}–${num((index + 1) * size)}s`;

// One step of each algorithm: decide(time) returns { allowed, words, state }
const ALGORITHMS = {
    'token-bucket': ({ capacity, refillPerSecond: rate }) => {
        let tokens = capacity;
        let last = 0;
        const level = [{ time: 0, tokens: capacity }];
        return (time) => {
            const refilled = Math.min(capacity, tokens + (time - last) * rate);
            if (refilled >= capacity - EPS && tokens < capacity - EPS) level.push({ time: last + (capacity - tokens) / rate, tokens: capacity });
            const before = refilled;
            level.push({ time, tokens: before });
            const allowed = before >= 1 - EPS;
            tokens = allowed ? before - 1 : before;
            last = time;
            level.push({ time, tokens });
            const words = allowed
                ? `allowed: it takes a token, leaving ${num(tokens)} of ${capacity}.`
                : `rejected: the bucket ${before < 0.005 ? 'is empty' : `has only ${num(before)} of a token`}, and the next whole one arrives in ${secs((1 - before) / rate)}.`;
            return { allowed, words, state: { tokens, before, capacity, rate, level: [...level] } };
        };
    },
    'leaky-bucket': ({ capacity, leakPerSecond: rate }) => {
        const interval = 1 / rate;
        let queue = [];
        let lastLeave = 0;
        let id = 0;
        return (time) => {
            queue = queue.filter((entry) => entry.leaves > time + EPS);
            id += 1;
            if (queue.length >= capacity) {
                return { allowed: false, words: `rejected: the bucket is full with ${plural(queue.length, 'request')} waiting; the next one leaks out at ${secs(queue[0].leaves)}.`, state: { queue: [...queue], capacity, rate } };
            }
            const leaves = Math.max(time, lastLeave) + interval;
            lastLeave = leaves;
            queue.push({ id, arrived: time, leaves });
            return { allowed: true, leaves, words: `queued in place ${queue.length} of ${capacity}: it leaks out at ${secs(leaves)}, ${secs(leaves - time)} after it arrived.`, state: { queue: [...queue], capacity, rate } };
        };
    },
    'fixed-window': ({ window, limit }) => {
        const counts = new Map();
        return (time) => {
            const index = Math.floor(time / window + EPS);
            const used = counts.get(index) ?? 0;
            const allowed = used < limit;
            if (allowed) counts.set(index, used + 1);
            const count = counts.get(index) ?? 0;
            const words = allowed
                ? `allowed: ${count} of ${limit} in the window ${windowLabel(index, window)}.`
                : `rejected: the window ${windowLabel(index, window)} has already allowed ${limit} of ${limit}; it resets at ${secs((index + 1) * window)}.`;
            return { allowed, words, state: { index, count, limit, window, counts: Object.fromEntries(counts) } };
        };
    },
    'sliding-log': ({ window, limit }) => {
        let log = [];
        return (time) => {
            log = log.filter((stamp) => stamp > time - window + EPS);
            const allowed = log.length < limit;
            const oldest = log[0];
            if (allowed) log.push(time);
            const words = allowed
                ? `allowed: ${log.length} of ${limit} in the last ${secs(window)} (since ${secs(Math.max(0, time - window))}).`
                : `rejected: ${limit} requests already in the last ${secs(window)}; the oldest, at ${secs(oldest)}, drops out at ${secs(oldest + window)}.`;
            return { allowed, words, state: { log: [...log], limit, window, from: time - window } };
        };
    },
    'sliding-counter': ({ window, limit }) => {
        const counts = new Map();
        return (time) => {
            const index = Math.floor(time / window + EPS);
            const previous = counts.get(index - 1) ?? 0;
            const current = counts.get(index) ?? 0;
            const into = time - index * window;
            const weight = Math.max(0, 1 - into / window);
            const estimate = previous * weight + current;
            const allowed = estimate < limit - EPS;
            if (allowed) counts.set(index, current + 1);
            const sum = `${previous} × ${num(weight)} + ${current} = ${num(estimate)}`;
            const words = allowed
                ? `allowed: the estimate ${sum} is under ${limit}.`
                : `rejected: the estimate ${sum} has reached ${limit}.`;
            // The panel shows the sum that decided this request, so `current` is the count before it
            return { allowed, words, state: { index, previous, current, weight, estimate, limit, window } };
        };
    },
};

const INTRO = {
    'token-bucket': ({ capacity, refillPerSecond }) => `A bucket of ${plural(capacity, 'token')}, full to start, refilling ${num(refillPerSecond)} per second. Each request takes a token or is rejected.`,
    'leaky-bucket': ({ capacity, leakPerSecond }) => `A queue of ${capacity} that leaks ${num(leakPerSecond)} request${leakPerSecond === 1 ? '' : 's'} per second, one every ${secs(1 / leakPerSecond)}. Requests wait their turn; a full queue rejects.`,
    'fixed-window': ({ window, limit }) => `At most ${limit} requests in each ${secs(window)} window: ${windowLabel(0, window)}, ${windowLabel(1, window)} and so on. The count resets at each boundary.`,
    'sliding-log': ({ window, limit }) => `At most ${limit} requests in any ${secs(window)}: the limiter keeps the time of every allowed request and forgets those older than ${secs(window)}.`,
    'sliding-counter': ({ window, limit }) => `At most ${limit} per ${secs(window)}, estimated from two counters: this window's count plus the previous window's, weighted by how much of it still overlaps the last ${secs(window)}.`,
};

export const rateLimiterFrames = (props) => {
    const { algorithm } = props;
    const times = expandRequests(props.requests);
    const decide = ALGORITHMS[algorithm](props);
    const results = times.map((time) => ({ time, allowed: null }));
    const frames = [];
    let allowedCount = 0;
    let rejectedCount = 0;
    let state = null;
    const push = (current, time, message) => frames.push({ algorithm, results: results.map((result) => ({ ...result })), current, time, state, allowed: allowedCount, rejected: rejectedCount, message });

    state = algorithm === 'token-bucket' ? { tokens: props.capacity, before: props.capacity, capacity: props.capacity, rate: props.refillPerSecond, level: [{ time: 0, tokens: props.capacity }] }
        : algorithm === 'leaky-bucket' ? { queue: [], capacity: props.capacity, rate: props.leakPerSecond }
            : algorithm === 'sliding-log' ? { log: [], limit: props.limit, window: props.window, from: -props.window }
                : { index: 0, count: 0, previous: 0, current: 0, weight: 1, estimate: 0, limit: props.limit, window: props.window, counts: {} };
    push(null, 0, `${INTRO[algorithm](props)} ${plural(times.length, 'request')} arrive.`);

    times.forEach((time, index) => {
        const verdict = decide(time);
        state = verdict.state;
        results[index].allowed = verdict.allowed;
        if (verdict.leaves !== undefined) results[index].leaves = verdict.leaves;
        if (verdict.allowed) allowedCount += 1; else rejectedCount += 1;
        push(index, time, `${secs(time)} · request ${index + 1}: ${verdict.words}`);
    });

    // The summary shows what each algorithm lets through at its busiest
    const allowedTimes = results.filter((result) => result.allowed).map((result) => result.time);
    const parts = [`Allowed ${allowedCount} of ${times.length} (${pct(allowedCount, times.length)}), rejected ${rejectedCount}.`];
    if (algorithm === 'token-bucket') {
        const busiest = busiestSpan(allowedTimes, 1);
        parts.push(`The busiest second let ${busiest.count} through (from ${secs(busiest.from)}): a full bucket allows a burst of ${props.capacity}, then requests pass at the refill rate of ${num(props.refillPerSecond)}/s.`);
    } else if (algorithm === 'leaky-bucket') {
        const leaves = results.filter((result) => result.allowed).map((result) => result.leaves);
        const busiest = busiestSpan(leaves, 1);
        const longest = Math.max(0, ...results.filter((result) => result.allowed).map((result) => result.leaves - result.time));
        parts.push(`However bursty the arrivals, at most ${busiest.count} left in any second: bursts wait in the queue instead (the longest wait was ${secs(longest)}) or are dropped when it is full.`);
    } else {
        const busiest = busiestSpan(allowedTimes, props.window);
        const span = `${secs(busiest.from)}–${secs(busiest.to)}`;
        if (algorithm === 'fixed-window') {
            parts.push(busiest.count > props.limit
                ? `But ${busiest.count} were allowed within one ${secs(props.window)} span (${span}), ${num(busiest.count / props.limit, 1)}× the limit: the two sides of a window boundary each get a full allowance.`
                : `The busiest ${secs(props.window)} span allowed ${busiest.count}. Put a burst just before a boundary and another just after it to see a fixed window let through up to twice the limit.`);
        } else if (algorithm === 'sliding-log') {
            parts.push(`No ${secs(props.window)} span ever allowed more than ${props.limit} (the busiest had ${busiest.count}): exact, at the cost of storing a timestamp per request.`);
        } else {
            parts.push(`The busiest ${secs(props.window)} span allowed ${busiest.count} (limit ${props.limit}). Two counters approximate the sliding log; the estimate assumes the previous window's requests were spread evenly.`);
        }
    }
    push(null, times.at(-1), parts.join(' '));
    return frames;
};
