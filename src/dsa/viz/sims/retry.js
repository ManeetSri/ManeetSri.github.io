// Retries with exponential backoff, jitter and an optional circuit breaker, for ```visual retry.
// Props: { base, factor = 2, cap, attempts, jitter: none | full | equal | decorrelated, seed = 1,
//   failUntil = 0 (the first attempt that succeeds; 0 means none do), breaker?: { threshold, cooldown } }.
// Attempts take no time; the wait before retry n (n = 0, 1, …) is built from min(cap, base × factorⁿ):
//   none: exactly that; full: random in [0, it]; equal: half of it plus random in [0, half];
//   decorrelated (AWS): min(cap, random in [base, 3 × the previous wait]), starting from base.
// Random numbers come from SplitMix64 (the same generator as DesignKit's SeededGenerator), so a seed always
// gives the same schedule. The breaker opens after `threshold` failures in a row; while open, calls fail at
// once without reaching the server; `cooldown` seconds after opening it is half-open, and the next call is a
// trial that closes it on success or opens it again on failure.
// Each frame: { attempts (the whole run), shown, current, until, segments, end, message }.
import { checkNumber, checkTitle, isObject, listing, num, plural, quote, secs, superscript, unknownField } from './common.js';

export const JITTERS = ['none', 'full', 'equal', 'decorrelated'];
const FIELDS = ['title', 'base', 'factor', 'cap', 'attempts', 'jitter', 'seed', 'failUntil', 'breaker'];
const MAX_ATTEMPTS = 20;
const MASK = (1n << 64n) - 1n;

// SplitMix64: returns a function giving the next 64-bit value as a BigInt
export const splitMix64 = (seed) => {
    let state = BigInt(seed) & MASK;
    return () => {
        state = (state + 0x9E3779B97F4A7C15n) & MASK;
        let value = state;
        value = ((value ^ (value >> 30n)) * 0xBF58476D1CE4E5B9n) & MASK;
        value = ((value ^ (value >> 27n)) * 0x94D049BB133111EBn) & MASK;
        return value ^ (value >> 31n);
    };
};
// A uniform number in [0, 1) from the top 53 bits
export const unitRandom = (next) => Number(next() >> 11n) / 2 ** 53;

export const retrySchema = (props) => {
    if (!isObject(props)) return 'expected settings with `base`, `cap` and `attempts`';
    const problem = unknownField(props, FIELDS) ?? checkTitle(props)
        ?? checkNumber(props.base, 'base', { above: 0 })
        ?? checkNumber(props.factor, 'factor', { min: 1, optional: true })
        ?? checkNumber(props.cap, 'cap', { above: 0 })
        ?? (props.cap < props.base ? `\`cap\` (${props.cap}) must be at least \`base\` (${props.base})` : null)
        ?? checkNumber(props.attempts, 'attempts', { whole: true, min: 1, max: MAX_ATTEMPTS })
        ?? (props.jitter === undefined || JITTERS.includes(props.jitter) ? null : `unknown \`jitter\` ${quote(props.jitter)}: use none, full, equal or decorrelated`)
        ?? checkNumber(props.seed, 'seed', { whole: true, min: 0, max: Number.MAX_SAFE_INTEGER, optional: true })
        ?? checkNumber(props.failUntil, 'failUntil', { whole: true, min: 0, optional: true })
        ?? (props.failUntil > props.attempts ? `\`failUntil\` (${props.failUntil}) is after the last attempt (${props.attempts}); use 0 if no attempt should succeed` : null);
    if (problem) return problem;
    if (props.breaker === undefined) return true;
    if (!isObject(props.breaker)) return '`breaker` must be { threshold, cooldown }';
    const issue = unknownField(props.breaker, ['threshold', 'cooldown'])
        ?? checkNumber(props.breaker.threshold, 'threshold', { whole: true, min: 1 })
        ?? checkNumber(props.breaker.cooldown, 'cooldown', { above: 0 });
    return issue ? `breaker: ${issue}` : true;
};

const settings = (props) => ({
    base: props.base,
    factor: props.factor ?? 2,
    cap: props.cap,
    attempts: props.attempts,
    jitter: props.jitter ?? 'none',
    seed: props.seed ?? 1,
    failUntil: props.failUntil ?? 0,
    breaker: props.breaker ?? null,
});

// The wait before retry `retry` (0-based): { delay, ceiling, low, high, raw }. low/high bound the random pick.
const nextWait = (config, retry, previous, random) => {
    const { base, factor, cap, jitter } = config;
    const raw = base * factor ** retry;
    const ceiling = Math.min(cap, raw);
    if (jitter === 'full') return { delay: random() * ceiling, ceiling, low: 0, high: ceiling, raw };
    if (jitter === 'equal') return { delay: ceiling / 2 + random() * (ceiling / 2), ceiling, low: ceiling / 2, high: ceiling, raw };
    if (jitter === 'decorrelated') {
        const high = previous * 3;
        return { delay: Math.min(cap, base + random() * (high - base)), ceiling: Math.min(cap, high), low: base, high, raw, previous };
    }
    return { delay: ceiling, ceiling, low: ceiling, high: ceiling, raw };
};

// The whole run: every attempt, the breaker's states over time, and when it ends
export const retryRun = (props) => {
    const config = settings(props);
    const next = splitMix64(config.seed);
    const random = () => unitRandom(next);
    const { breaker } = config;
    const attempts = [];
    const segments = [];
    let time = 0;
    let previous = config.base;
    let state = 'closed';
    let since = 0;
    let failures = 0;
    let openedAt = 0;
    const enter = (to, at) => {
        if (at > since) segments.push({ state, from: since, to: at });
        state = to;
        since = at;
    };
    for (let n = 1; n <= config.attempts; n += 1) {
        let trial = false;
        let halfOpenAt = null;
        if (breaker && state === 'open' && time >= openedAt + breaker.cooldown - 1e-9) {
            halfOpenAt = openedAt + breaker.cooldown;
            enter('half-open', halfOpenAt);
            trial = true;
        }
        const met = breaker ? state : null;
        let outcome;
        let change = null;
        if (breaker && state === 'open') {
            outcome = 'rejected';
        } else {
            const ok = config.failUntil !== 0 && n >= config.failUntil;
            outcome = ok ? 'success' : 'failure';
            if (breaker && state === 'half-open') {
                change = ok ? 'closed' : 'opened';
                if (ok) failures = 0;
                else openedAt = time;
                enter(ok ? 'closed' : 'open', time);
            } else if (breaker) {
                failures = ok ? 0 : failures + 1;
                if (failures >= breaker.threshold) {
                    change = 'opened';
                    openedAt = time;
                    enter('open', time);
                }
            }
        }
        const attempt = { n, time, outcome, breaker: met, trial, halfOpenAt, change, failures: change === 'opened' && !trial ? failures : null, openUntil: breaker && state === 'open' ? openedAt + breaker.cooldown : null, wait: null };
        if (change === 'opened') failures = 0;
        attempts.push(attempt);
        if (outcome === 'success' || n === config.attempts) break;
        attempt.wait = nextWait(config, n - 1, previous, random);
        previous = attempt.wait.delay;
        time += attempt.wait.delay;
    }
    enter(state, time);
    if (breaker && segments.length === 0) segments.push({ state, from: 0, to: 0 });
    return { config, attempts, segments, end: time };
};

const waitWords = (config, wait, retry) => {
    const { base, factor, cap, jitter } = config;
    const formula = `${num(base)} × ${num(factor)}${superscript(retry)}`;
    const exact = wait.raw > cap ? `${formula} = ${secs(wait.raw)}, capped at ${secs(cap)}` : `${formula}`;
    if (jitter === 'none') return exact;
    if (jitter === 'full') return `full jitter picks between 0 and ${secs(wait.ceiling)} (${exact})`;
    if (jitter === 'equal') return `equal jitter keeps half of ${secs(wait.ceiling)} and adds a random part, so between ${secs(wait.low)} and ${secs(wait.high)}`;
    return `decorrelated jitter picks between ${secs(base)} and 3 × the last wait (${secs(wait.previous)})${wait.high > cap ? `, capped at ${secs(cap)}` : ''}`;
};

const ORDINALS = ['first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth'];
const ordinal = (count) => ORDINALS[count - 1] ?? `${count}th`;

export const retryFrames = (props) => {
    const run = retryRun(props);
    const { config, attempts, segments, end } = run;
    const { breaker } = config;
    const frames = [];
    const push = (shown, current, until, message) => frames.push({ attempts, shown, current, until, segments, end, breaker: Boolean(breaker), message });

    const jitterWords = { none: 'no jitter', full: `full jitter (seed ${config.seed})`, equal: `equal jitter (seed ${config.seed})`, decorrelated: `decorrelated jitter (seed ${config.seed})` }[config.jitter];
    const serverWords = config.failUntil === 0 ? 'The server fails every call.' : config.failUntil === 1 ? 'The server answers the first call.' : `The server fails every call until attempt ${config.failUntil}.`;
    const breakerWords = breaker ? ` A circuit breaker opens after ${plural(breaker.threshold, 'failure')} in a row and lets a trial call through ${secs(breaker.cooldown)} later.` : '';
    push(0, null, 0, `Up to ${plural(config.attempts, 'attempt')}. Retry n waits min(${secs(config.cap)}, ${secs(config.base)} × ${num(config.factor)}ⁿ), with ${jitterWords}. ${serverWords}${breakerWords}`);

    attempts.forEach((attempt, index) => {
        const at = `Attempt ${attempt.n} at ${secs(attempt.time)}`;
        const parts = [];
        if (attempt.trial) parts.push(`The cooldown ended at ${secs(attempt.halfOpenAt)}, so the breaker is half-open and ${at.toLowerCase()} is the trial call.`);
        if (attempt.outcome === 'rejected') parts.push(`${at} never reaches the server: the breaker is open until ${secs(attempt.openUntil)}, so it fails at once.`);
        else if (attempt.outcome === 'success') parts.push(`${attempt.trial ? 'It' : at} succeeds${attempt.change === 'closed' ? ', so the breaker closes' : ''}.`);
        else if (attempt.change === 'opened') parts.push(attempt.trial ? `It fails, so the breaker opens again until ${secs(attempt.openUntil)}.` : `${at} fails: the ${ordinal(attempt.failures)} failure in a row, so the breaker opens until ${secs(attempt.openUntil)}.`);
        else parts.push(`${attempt.trial ? 'It' : at} fails.`);
        if (attempt.wait) parts.push(`Wait ${secs(attempt.wait.delay)} before attempt ${attempt.n + 1}: ${waitWords(config, attempt.wait, attempt.n - 1)}.`);
        else if (attempt.outcome !== 'success') parts.push('That was the last attempt: give up.');
        push(index + 1, index, attempt.time, parts.join(' '));
    });

    const last = attempts.at(-1);
    const rejected = attempts.filter((attempt) => attempt.outcome === 'rejected');
    const reached = attempts.length - rejected.length;
    const summary = [];
    if (last.outcome === 'success') summary.push(`Succeeded on attempt ${last.n} at ${secs(last.time)}, after ${plural(last.n - 1, 'retry', 'retries')}.`);
    else summary.push(`Gave up after ${plural(attempts.length, 'attempt')} and ${secs(end)}.`);
    if (breaker) {
        summary.push(rejected.length ? `The server saw ${plural(reached, 'call')}; the open breaker failed the other ${rejected.length} at once, sparing it the load.` : `The breaker never opened, so all ${plural(reached, 'call')} reached the server.`);
        const blocked = rejected.find((attempt) => config.failUntil !== 0 && attempt.n >= config.failUntil);
        if (blocked) summary.push(`The server had recovered by attempt ${blocked.n}, but the open breaker kept that call from finding out.`);
    }
    if (config.jitter !== 'none' && attempts.length > 1) {
        const plain = retryRun({ ...props, jitter: 'none', breaker: undefined, failUntil: 0 }).attempts.slice(0, attempts.length).map((attempt) => num(attempt.time));
        summary.push(`Without jitter the attempts would land at ${listing(plain)} s, the same moments as every other client that failed together.`);
    }
    push(attempts.length, null, end, summary.join(' '));
    return frames;
};
