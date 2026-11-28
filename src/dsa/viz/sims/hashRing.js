// Consistent hashing on a ring, for ```visual hashRing.
// Props: { nodes: [A, B, C], vnodes: 1–8, keys: [user:1, …], steps: [{ add: D } | { remove: B }],
//   hash: mixed (default) | fnv1a }.
// Every node puts `vnodes` points on a 32-bit ring, at hash("A#0"), hash("A#1"), …; a key belongs to the first
// point clockwise from hash(key). Hashes are FNV-1a 32-bit over the UTF-8 bytes. FNV-1a barely changes its high
// bits when only the last character changes, so user:1, user:2, … would bunch together on the ring; `mixed`
// (the default) runs MurmurHash3's 32-bit finalizer over the FNV-1a value to spread them. `fnv1a` shows the
// raw clustering. Each step is compared with naive hash % N placement over the node list in order.
// Each frame: { nodes, points: [{ node, vnode, at (0–1), fresh, gone }], keys: [{ key, at, owner, from }],
//   loads, shares, moved, naiveMoved, showKeys, message }.
import { checkNumber, checkTitle, isNumber, isObject, isText, listing, pct, plural, quote, unknownField } from './common.js';

export const MAX_NODES = 8;
const MAX_KEYS = 60;
const FIELDS = ['title', 'nodes', 'vnodes', 'keys', 'steps', 'hash'];
const RING = 2 ** 32;

export const fnv1a32 = (text) => {
    let hash = 0x811c9dc5;
    for (const byte of new TextEncoder().encode(text)) {
        hash ^= byte;
        hash = Math.imul(hash, 0x01000193) >>> 0;
    }
    return hash >>> 0;
};
export const fmix32 = (value) => {
    let hash = value >>> 0;
    hash ^= hash >>> 16;
    hash = Math.imul(hash, 0x85ebca6b);
    hash ^= hash >>> 13;
    hash = Math.imul(hash, 0xc2b2ae35);
    hash ^= hash >>> 16;
    return hash >>> 0;
};
export const ringHash = (text, mode = 'mixed') => (mode === 'fnv1a' ? fnv1a32(text) : fmix32(fnv1a32(text)));

const nameList = (value) => Array.isArray(value) && value.every((item) => isText(item) || isNumber(item));

export const hashRingSchema = (props) => {
    if (!isObject(props)) return 'expected settings with `nodes` and `keys`';
    const problem = unknownField(props, FIELDS) ?? checkTitle(props);
    if (problem) return problem;
    const { nodes, keys, steps = [] } = props;
    if (!nameList(nodes) || nodes.length === 0) return '`nodes` must be a list of node names, such as [A, B, C]';
    const names = nodes.map(String);
    const twice = names.find((name, index) => names.indexOf(name) !== index);
    if (twice) return `node ${quote(twice)} is listed twice`;
    const issue = checkNumber(props.vnodes, 'vnodes', { whole: true, min: 1, max: 8, optional: true })
        ?? (props.hash === undefined || ['mixed', 'fnv1a'].includes(props.hash) ? null : `unknown \`hash\` ${quote(props.hash)}: use mixed or fnv1a`);
    if (issue) return issue;
    if (!nameList(keys) || keys.length === 0) return '`keys` must be a list of keys, such as [user:1, user:2, photo:9]';
    if (keys.length > MAX_KEYS) return `\`keys\` has ${keys.length} keys; ${MAX_KEYS} is the most the ring can show clearly`;
    const keyNames = keys.map(String);
    const repeated = keyNames.find((key, index) => keyNames.indexOf(key) !== index);
    if (repeated) return `key ${quote(repeated)} is listed twice`;
    if (!Array.isArray(steps)) return '`steps` must be a list such as [{ add: D }, { remove: B }]';
    const live = new Set(names);
    const seen = new Set(names);
    for (const [index, step] of steps.entries()) {
        const where = `steps[${index}]`;
        if (!isObject(step) || Object.keys(step).length !== 1 || !('add' in step || 'remove' in step)) return `${where} must be { add: name } or { remove: name }, not ${quote(step)}`;
        const name = step.add ?? step.remove;
        if (!(isText(name) || isNumber(name))) return `${where}: the node name must be text, not ${quote(name)}`;
        const node = String(name);
        if ('add' in step) {
            if (live.has(node)) return `${where} adds ${node}, which is already on the ring`;
            live.add(node);
            seen.add(node);
        } else {
            if (!live.has(node)) return `${where} removes ${node}, which isn't on the ring at that point`;
            if (live.size === 1) return `${where} would remove the last node; keep at least one`;
            live.delete(node);
        }
    }
    if (seen.size > MAX_NODES) return `${seen.size} different nodes appear; at most ${MAX_NODES} can have their own colour`;
    return true;
};

// Points sorted clockwise
const ringPoints = (nodes, vnodes, mode) => nodes
    .flatMap((node) => Array.from({ length: vnodes }, (_, vnode) => ({ node, vnode, hash: ringHash(`${node}#${vnode}`, mode) })))
    .sort((a, b) => a.hash - b.hash || (a.node < b.node ? -1 : 1));

export const ownerOf = (hash, points) => (points.find((point) => point.hash >= hash) ?? points[0]).node;

// How much of the ring each node owns: each point owns the arc from the point before it
const sharesOf = (nodes, points) => {
    const shares = Object.fromEntries(nodes.map((node) => [node, 0]));
    points.forEach((point, index) => {
        const before = index === 0 ? points.at(-1).hash - RING : points[index - 1].hash;
        shares[point.node] += (point.hash - before) / RING;
    });
    return shares;
};

export const hashRingFrames = (props) => {
    const vnodes = props.vnodes ?? 1;
    const mode = props.hash ?? 'mixed';
    const steps = props.steps ?? [];
    let nodes = props.nodes.map(String);
    const keys = props.keys.map(String).map((key) => ({ key, hash: ringHash(key, mode) }));
    // Colours follow the order nodes first appear in
    const order = [...nodes, ...steps.filter((step) => 'add' in step).map((step) => String(step.add))];
    const frames = [];
    let points = ringPoints(nodes, vnodes, mode);
    let owners = Object.fromEntries(keys.map(({ key, hash }) => [key, ownerOf(hash, points)]));
    let totalMoved = 0;
    let totalNaive = 0;

    const loadsOf = () => Object.fromEntries(nodes.map((node) => [node, keys.filter(({ key }) => owners[key] === node).length]));
    const push = ({ fresh = null, gone = [], from = {}, moved = null, naiveMoved = null, showKeys = true }, message) => frames.push({
        nodes: [...nodes],
        order,
        vnodes,
        points: [
            ...points.map((point) => ({ node: point.node, vnode: point.vnode, at: point.hash / RING, fresh: point.node === fresh, gone: false })),
            ...gone.map((point) => ({ node: point.node, vnode: point.vnode, at: point.hash / RING, fresh: false, gone: true })),
        ],
        keys: keys.map(({ key, hash }) => ({ key, at: hash / RING, owner: owners[key], from: from[key] ?? null })),
        loads: loadsOf(),
        shares: sharesOf(nodes, points),
        moved,
        naiveMoved,
        showKeys,
        message,
    });

    const pointWords = vnodes === 1 ? `one point each, at hash("${nodes[0]}#0") and so on` : `${vnodes} virtual nodes each, at hash("${nodes[0]}#0") to hash("${nodes[0]}#${vnodes - 1}") and so on`;
    push({ showKeys: false }, `${plural(nodes.length, 'node')} on a ring of 2³² positions, ${pointWords}. Each point owns the arc counter-clockwise back to the point before it.`);

    const balance = () => {
        const loads = loadsOf();
        const counts = Object.values(loads);
        return `${listing(nodes.map((node) => `${node} ${loads[node]}`))}${counts.length > 1 && Math.min(...counts) > 0 ? ` (the busiest has ${(Math.max(...counts) / Math.min(...counts)).toFixed(1)}× the quietest)` : ''}`;
    };
    push({}, `${plural(keys.length, 'key')} each go clockwise from hash(key) to the next point. Keys per node: ${balance()}.${vnodes === 1 ? ' With one point per node the arcs are uneven; virtual nodes even them out.' : ''}`);

    steps.forEach((step) => {
        const before = { ...owners };
        const naiveBefore = Object.fromEntries(keys.map(({ key, hash }) => [key, nodes[hash % nodes.length]]));
        const adding = 'add' in step;
        const node = String(adding ? step.add : step.remove);
        const oldPoints = points;
        const previousCount = nodes.length;
        nodes = adding ? [...nodes, node] : nodes.filter((name) => name !== node);
        points = ringPoints(nodes, vnodes, mode);
        owners = Object.fromEntries(keys.map(({ key, hash }) => [key, ownerOf(hash, points)]));
        const from = Object.fromEntries(keys.filter(({ key }) => owners[key] !== before[key]).map(({ key }) => [key, before[key]]));
        const moved = Object.keys(from).length;
        const naiveMoved = keys.filter(({ key, hash }) => nodes[hash % nodes.length] !== naiveBefore[key]).length;
        totalMoved += moved;
        totalNaive += naiveMoved;
        const share = `${moved} of ${keys.length} keys ${moved === 1 ? 'moves' : 'move'} (${pct(moved, keys.length)})`;
        const naive = `With hash % N, going from ${previousCount} to ${nodes.length} nodes would move ${naiveMoved} (${pct(naiveMoved, keys.length)}).`;
        let message;
        if (adding) {
            message = `Add ${node}: its ${plural(vnodes, 'point')} ${vnodes === 1 ? 'lands' : 'land'} on the ring and ${vnodes === 1 ? 'takes' : 'take'} over the arc${vnodes === 1 ? '' : 's'} just counter-clockwise of ${vnodes === 1 ? 'it' : 'them'}. ${moved ? `${share}, all to ${node}` : 'No keys move: its arcs held none'}; no other key changes owner. ${naive}`;
        } else {
            const gainers = {};
            Object.keys(from).forEach((key) => { gainers[owners[key]] = (gainers[owners[key]] ?? 0) + 1; });
            const split = listing(Object.entries(gainers).map(([name, count]) => `${name} (${count})`));
            const where = Object.keys(gainers).length === 1 ? `all to ${Object.keys(gainers)[0]}` : `split between ${split}`;
            message = `Remove ${node}: each of its arcs passes to the next point clockwise. ${moved ? `${share}, ${where}` : `No keys move, since it owned none`}; nothing else moves. ${naive}`;
        }
        push({ fresh: adding ? node : null, gone: adding ? [] : oldPoints.filter((point) => point.node === node), from, moved, naiveMoved }, message);
    });

    if (steps.length > 0) {
        push({}, `After ${plural(steps.length, 'change')}, keys per node: ${balance()}. The ring moved ${totalMoved} key placements in all, about K/N each time; hash % N moved ${totalNaive}.`);
    }
    return frames;
};
