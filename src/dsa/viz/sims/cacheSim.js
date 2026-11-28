// A read-through cache with one or more layers in front of an origin, for ```visual cacheSim.
// Props: { layers: [{ name, capacity }] (fastest first), origin, policy: lru | lfu | fifo, ttl?, requests }.
// A request is a key, which arrives a second after the one before (the first at 0), or { key, at }.
// A lookup tries each layer from the top. A hit lower down is copied up into the layers above it (promotion);
// a miss everywhere fetches from the origin and stores the key in every layer. A full layer evicts by policy.
// With a TTL, an entry expires `ttl` seconds after the origin returned it, in every layer at once.
// Each frame: { time, current, layers: [{ name, capacity, entries, gone, status, hits, lookups }],
//   origin: { name, fetches, active }, timeline: [{ key, time, served }], message }.
// Entries are listed from the one kept longest to the one evicted next. `served` is a layer index, -1 for the
// origin, or null for a request still to come.
import { checkNumber, checkTitle, isNumber, isObject, isText, listing, num, pct, plural, quote, secs, unknownField } from './common.js';

export const CACHE_POLICIES = ['lru', 'lfu', 'fifo'];
export const POLICY_NAMES = { lru: 'LRU', lfu: 'LFU', fifo: 'FIFO' };
// What the two ends of a layer's list mean under each policy: [first, last]
export const ORDER_ENDS = { lru: ['most recent', 'least recent'], lfu: ['most used', 'least used'], fifo: ['newest', 'oldest'] };
const LIMITS = { layers: 4, capacity: 24, requests: 80 };
const FIELDS = ['title', 'layers', 'origin', 'policy', 'ttl', 'requests'];

const keyOf = (request) => (isObject(request) ? request.key : request);

// Each request's key and arrival time
export const requestTimes = (requests) => {
    let time = null;
    return requests.map((request) => {
        const at = isObject(request) ? request.at : undefined;
        time = at ?? (time === null ? 0 : time + 1);
        return { key: String(keyOf(request)), time };
    });
};

const checkRequests = (requests) => {
    if (!Array.isArray(requests) || requests.length === 0) return '`requests` must be a list of keys, such as [a, b, a, { key: c, at: 12 }]';
    if (requests.length > LIMITS.requests) return `\`requests\` has ${requests.length} items; keep it to ${LIMITS.requests} or fewer so the steps stay followable`;
    for (const [index, request] of requests.entries()) {
        const where = `requests[${index}]`;
        if (isObject(request)) {
            const extra = unknownField(request, ['key', 'at'], `${where}: `);
            if (extra) return extra;
            if (request.at !== undefined && (!isNumber(request.at) || request.at < 0)) return `${where}: \`at\` must be a time in seconds, 0 or later, not ${quote(request.at)}`;
        }
        const key = keyOf(request);
        if (!(isText(key) || isNumber(key))) return `${where} must be a key (text or a number) or { key, at }, not ${quote(request)}`;
    }
    const times = requestTimes(requests);
    const back = times.findIndex((entry, index) => index > 0 && entry.time < times[index - 1].time);
    if (back > 0) return `requests must be in time order: requests[${back}] (${times[back].key}) is at ${secs(times[back].time)}, before the one before it at ${secs(times[back - 1].time)}`;
    return null;
};

export const cacheSimSchema = (props) => {
    if (!isObject(props)) return 'expected settings with `layers` and `requests`';
    const problem = unknownField(props, FIELDS) ?? checkTitle(props);
    if (problem) return problem;
    const { layers, origin, policy, ttl, requests } = props;
    if (!Array.isArray(layers) || layers.length === 0) return '`layers` must be a list of cache layers, fastest first, such as [{ name: Memory, capacity: 3 }, { name: Disk, capacity: 6 }]';
    if (layers.length > LIMITS.layers) return `\`layers\` has ${layers.length} layers; at most ${LIMITS.layers} fit`;
    for (const [index, layer] of layers.entries()) {
        const where = `layers[${index}]`;
        if (!isObject(layer)) return `${where} must be { name, capacity }, not ${quote(layer)}`;
        const issue = unknownField(layer, ['name', 'capacity'], `${where}: `)
            ?? (isText(layer.name) ? null : `${where} needs a \`name\`, such as Memory`)
            ?? checkNumber(layer.capacity, 'capacity', { whole: true, min: 1, max: LIMITS.capacity });
        if (issue) return issue.startsWith(where) ? issue : `${where} (${layer.name}): ${issue}`;
    }
    const names = layers.map((layer) => layer.name);
    const repeated = names.find((name, index) => names.indexOf(name) !== index);
    if (repeated) return `two layers are called ${quote(repeated)}; give each layer its own name`;
    if (origin !== undefined && !isText(origin)) return '`origin` must be text, such as Network';
    if (origin !== undefined && names.includes(origin)) return `\`origin\` is called ${quote(origin)}, like one of the layers; give it its own name`;
    if (policy !== undefined && !CACHE_POLICIES.includes(policy)) return `unknown \`policy\` ${quote(policy)}: use lru, lfu or fifo`;
    return checkNumber(ttl, 'ttl', { above: 0, optional: true }) ?? checkRequests(requests) ?? true;
};

// The policy's victim: the entry evicted next
const RANK = {
    lru: (a, b) => b.used - a.used,
    fifo: (a, b) => b.order - a.order,
    lfu: (a, b) => b.count - a.count || b.used - a.used,
};
const ordered = (entries, policy) => [...entries].sort(RANK[policy]);
const victimOf = (entries, policy) => ordered(entries, policy).at(-1);

const evictionReason = (victim, entries, policy) => {
    if (policy === 'lru') return `it was the least recently used (last used at ${secs(victim.usedAt)})`;
    if (policy === 'fifo') return `it was the oldest (stored at ${secs(victim.storedAt)})`;
    const tied = entries.filter((entry) => entry.count === victim.count).length > 1;
    return `it had the fewest uses (${victim.count})${tied ? ', and was the least recent of those' : ''}`;
};

const hitNote = (entry, policy) => {
    if (policy === 'lru') return `${entry.key} becomes the most recently used.`;
    if (policy === 'lfu') return `${entry.key} has now been used ${plural(entry.count, 'time')} here.`;
    return `FIFO ignores hits, so ${entry.key} keeps its place in the queue.`;
};

export const cacheSimFrames = (props) => {
    const policy = props.policy ?? 'lru';
    const ttl = props.ttl;
    const originName = props.origin ?? 'Origin';
    const requests = requestTimes(props.requests);
    const layers = props.layers.map((layer) => ({ name: layer.name, capacity: layer.capacity, entries: [], hits: 0, lookups: 0 }));
    const served = requests.map(() => null);
    const origin = { name: originName, fetches: 0 };
    let tick = 0;
    let order = 0;
    const frames = [];

    // marks: { status: [per layer], tones: [per layer { key: tone }], gone: [per layer [{ key, reason }]], active }
    const push = (time, current, marks, message) => frames.push({
        time,
        current,
        layers: layers.map((layer, index) => ({
            name: layer.name,
            capacity: layer.capacity,
            hits: layer.hits,
            lookups: layer.lookups,
            status: marks.status?.[index] ?? null,
            gone: marks.gone?.[index] ?? [],
            entries: ordered(layer.entries, policy).map((entry) => ({
                key: entry.key,
                count: entry.count,
                left: ttl === undefined ? null : entry.expiresAt - time,
                tone: marks.tones?.[index]?.[entry.key] ?? null,
            })),
        })),
        origin: { name: origin.name, fetches: origin.fetches, active: Boolean(marks.active) },
        timeline: requests.map((request, index) => ({ key: request.key, time: request.time, served: served[index] })),
        message,
    });

    const layerWords = listing(layers.map((layer) => `${layer.name} (holds ${layer.capacity})`));
    const policyWords = {
        lru: 'LRU: a full layer drops the key used least recently.',
        lfu: 'LFU: a full layer drops the key used least often (the least recent of those on a tie).',
        fifo: 'FIFO: a full layer drops the key stored first, however often it is used.',
    }[policy];
    const ttlWords = ttl === undefined ? '' : ` Entries expire ${secs(ttl)} after ${originName} returns them.`;
    push(requests[0].time, null, {}, `${layers.length > 1 ? `${layerWords}, fastest first` : layerWords}, in front of ${originName}. ${policyWords}${ttlWords} ${plural(requests.length, 'request')} follow.`);

    requests.forEach(({ key, time }, index) => {
        const stamp = `${secs(time)} · GET ${key}`;
        // Expired entries leave every layer before the lookup
        if (ttl !== undefined) {
            const gone = layers.map((layer) => layer.entries.filter((entry) => entry.expiresAt <= time + 1e-9).map((entry) => ({ key: entry.key, reason: 'expired' })));
            if (gone.some((list) => list.length > 0)) {
                layers.forEach((layer) => { layer.entries = layer.entries.filter((entry) => entry.expiresAt > time + 1e-9); });
                const byKey = new Map();
                gone.forEach((list, layerIndex) => list.forEach(({ key: expired }) => byKey.set(expired, [...(byKey.get(expired) ?? []), layers[layerIndex].name])));
                const words = listing([...byKey].map(([expired, where]) => `${expired} (${listing(where)})`));
                push(time, index, { gone }, `${secs(time)}: before the next request, ${words} ${byKey.size === 1 ? 'is' : 'are'} past the ${secs(ttl)} TTL, so ${byKey.size === 1 ? 'it is' : 'they are'} dropped.`);
            }
        }

        const found = layers.findIndex((layer) => layer.entries.some((entry) => entry.key === key));
        const reached = found === -1 ? layers.length : found + 1;
        const status = layers.map((_, layerIndex) => (layerIndex < reached ? (layerIndex === found ? 'hit' : 'miss') : null));
        layers.slice(0, reached).forEach((layer) => { layer.lookups += 1; });
        const missed = layers.slice(0, found === -1 ? layers.length : found).map((layer) => layer.name);
        let source = null;
        if (found !== -1) {
            const layer = layers[found];
            layer.hits += 1;
            source = layer.entries.find((entry) => entry.key === key);
            tick += 1;
            source.used = tick;
            source.usedAt = time;
            source.count += 1;
            served[index] = found;
            const tones = layers.map((_, layerIndex) => (layerIndex === found ? { [key]: 'hit' } : {}));
            const lead = missed.length ? `miss in ${listing(missed)}, hit in ${layer.name}` : `hit in ${layer.name}`;
            push(time, index, { status, tones }, `${stamp}: ${lead}. ${hitNote(source, policy)}`);
        } else {
            served[index] = -1;
            origin.fetches += 1;
            push(time, index, { status, active: true }, `${stamp}: miss in ${listing(missed)}, so fetch it from ${originName}.`);
        }

        // Fill the layers above where it was found (or all of them after an origin fetch)
        const targets = layers.slice(0, found === -1 ? layers.length : found);
        if (targets.length === 0) return;
        const gone = layers.map(() => []);
        const tones = layers.map((_, layerIndex) => (layerIndex === found ? { [key]: 'hit' } : {}));
        const evictions = [];
        targets.forEach((layer, layerIndex) => {
            if (layer.entries.length >= layer.capacity) {
                const victim = victimOf(layer.entries, policy);
                evictions.push(`${layer.name} was full, so ${victim.key} goes: ${evictionReason(victim, layer.entries, policy)}`);
                layer.entries = layer.entries.filter((entry) => entry !== victim);
                gone[layerIndex].push({ key: victim.key, reason: 'evicted' });
            }
            tick += 1;
            order += 1;
            layer.entries.push({ key, used: tick, usedAt: time, count: 1, order, storedAt: time, expiresAt: source ? source.expiresAt : time + (ttl ?? Infinity) });
            tones[layerIndex][key] = 'new';
        });
        const into = listing(targets.map((layer) => layer.name));
        const lead = found === -1 ? `${originName} returns ${key}; store it in ${into}.` : `Copy ${key} up into ${into} so the next read is faster.`;
        push(time, index, { status, tones, gone, active: found === -1 }, `${lead}${evictions.length ? ` ${evictions.join('. ')}.` : ''}`);
    });

    const fromCache = served.filter((value) => value !== -1).length;
    const rates = layers.map((layer) => `${layer.name} hit ${layer.hits} of ${layer.lookups} (${pct(layer.hits, layer.lookups)})`).join('; ');
    const last = requests.at(-1).time;
    push(last, null, {}, `Done: ${rates}. ${originName} served ${plural(origin.fetches, 'request')}, so ${fromCache} of ${requests.length} (${pct(fromCache, requests.length)}) came from a cache.`);
    return frames;
};

// For the view: how long an entry has left, as text
export const ttlLeft = (left) => (left === null || left === Infinity ? null : `${num(Math.max(0, left), 1)}s`);
