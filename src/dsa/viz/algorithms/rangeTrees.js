// Segment trees and Fenwick trees as frames.

export const SEGMENT_CODE = `func query(_ node: Int, _ low: Int, _ high: Int, _ left: Int, _ right: Int) -> Int {
    if right < low || high < left { return 0 }               // no overlap
    if left <= low && high <= right { return tree[node] }    // fully covered
    let mid = (low + high) / 2                                // partial: ask both halves
    return query(2 * node, low, mid, left, right)
         + query(2 * node + 1, mid + 1, high, left, right)
}

func update(_ node: Int, _ low: Int, _ high: Int, _ index: Int, _ value: Int) {
    if low == high { tree[node] = value; return }
    let mid = (low + high) / 2
    if index <= mid { update(2 * node, low, mid, index, value) }
    else { update(2 * node + 1, mid + 1, high, index, value) }
    tree[node] = tree[2 * node] + tree[2 * node + 1]
}`;

// Tree nodes are numbered like a heap from 1. Each holds the sum of items[low...high].
const buildTree = (items) => {
    const nodes = {};
    const build = (node, low, high) => {
        if (low === high) {
            nodes[node] = { value: items[low], low, high, left: null, right: null, note: `${low}` };
            return items[low];
        }
        const mid = Math.floor((low + high) / 2);
        const sum = build(2 * node, low, mid) + build(2 * node + 1, mid + 1, high);
        nodes[node] = { value: sum, low, high, left: 2 * node, right: 2 * node + 1, note: `${low}–${high}` };
        return sum;
    };
    build(1, 0, items.length - 1);
    return { root: 1, nodes };
};

const cloneTree = (tree) => ({ root: tree.root, nodes: Object.fromEntries(Object.entries(tree.nodes).map(([id, node]) => [id, { ...node }])) });

// operations: [["query", left, right], ["update", index, value]]
export const segmentFrames = ({ items = [5, 3, 7, 9, 6, 4, 1, 2], operations = [['query', 2, 6], ['update', 3, 1], ['query', 2, 6]] } = {}) => {
    const values = [...items];
    let tree = buildTree(values);
    const frames = [{ tree: cloneTree(tree), marks: {}, items: [...values], line: 1, message: `Each node stores the sum of a range of the array (its range is shown beside it). The root covers everything: ${tree.nodes[1].value}.` }];
    operations.forEach(([kind, a, b]) => {
        if (kind === 'query') {
            const marks = {};
            const used = [];
            const visit = (node, low, high) => {
                if (b < low || high < a) {
                    marks[node] = 'out';
                    return 0;
                }
                if (a <= low && high <= b) {
                    marks[node] = 'found';
                    used.push(tree.nodes[node].value);
                    return tree.nodes[node].value;
                }
                marks[node] = 'path';
                const mid = Math.floor((low + high) / 2);
                return visit(2 * node, low, mid) + visit(2 * node + 1, mid + 1, high);
            };
            const total = visit(1, 0, values.length - 1);
            frames.push({ tree: cloneTree(tree), marks, items: [...values], range: [a, b], line: 3, message: `Sum of items[${a}...${b}]: green nodes lie fully inside the range and are used whole (${used.join(' + ')} = ${total}); amber ones are split; red ones are skipped. O(log n) nodes, not ${b - a + 1} items.` });
        } else {
            const marks = {};
            values[a] = b;
            const touch = (node, low, high) => {
                marks[node] = 'swap';
                if (low === high) return;
                const mid = Math.floor((low + high) / 2);
                if (a <= mid) touch(2 * node, low, mid);
                else touch(2 * node + 1, mid + 1, high);
            };
            touch(1, 0, values.length - 1);
            tree = buildTree(values);
            frames.push({ tree: cloneTree(tree), marks, items: [...values], line: 10, message: `Set items[${a}] = ${b}: only the ${Object.keys(marks).length} nodes on the path from that leaf to the root change.` });
        }
    });
    return frames;
};

export const FENWICK_CODE = `func prefixSum(_ i: Int) -> Int {          // sum of items[1...i]
    var i = i, total = 0
    while i > 0 {
        total += tree[i]
        i -= i & -i                          // drop the lowest set bit
    }
    return total
}

func add(_ i: Int, _ delta: Int) {
    var i = i
    while i < tree.count {
        tree[i] += delta
        i += i & -i                          // move to the next range that covers i
    }
}`;

const lowbit = (i) => i & -i;

// 1-indexed. tree[i] holds the sum of items[i - lowbit(i) + 1 ... i].
export const fenwickFrames = ({ items = [3, 2, -1, 6, 5, 4, -3, 3], query = 7, update = [3, 2] } = {}) => {
    const n = items.length;
    const tree = Array(n + 1).fill(0);
    for (let i = 1; i <= n; i += 1) {
        tree[i] += items[i - 1];
        const parent = i + lowbit(i);
        if (parent <= n) tree[parent] += tree[i];
    }
    const ranges = Array.from({ length: n + 1 }, (_, i) => (i === 0 ? null : [i - lowbit(i) + 1, i]));
    const frames = [];
    const snapshot = (marks, line, message) => frames.push({ tree: [...tree], ranges, marks, line, message });
    snapshot({}, 1, `Index i is responsible for the last lowbit(i) = i & -i items up to i: odd indexes hold one item, 4 holds four, 8 holds eight.`);
    let i = query;
    let total = 0;
    const path = [];
    while (i > 0) {
        total += tree[i];
        path.push(i);
        snapshot(Object.fromEntries(path.map((step) => [step, 'path'])), 4, `Add tree[${i}] (items ${ranges[i][0]}–${ranges[i][1]}): total ${total}. Next index: ${i} − ${lowbit(i)} = ${i - lowbit(i)}.`);
        i -= lowbit(i);
    }
    snapshot(Object.fromEntries(path.map((step) => [step, 'found'])), 7, `Sum of the first ${query} items = ${total}, from ${path.length} lookups.`);
    const [position, delta] = update;
    const touched = [];
    for (let j = position; j <= n; j += lowbit(j)) {
        tree[j] += delta;
        touched.push(j);
        snapshot(Object.fromEntries(touched.map((step) => [step, 'swap'])), 13, `add(${position}, ${delta}): tree[${j}] covers item ${position}, so it changes. Next: ${j} + ${lowbit(j)} = ${j + lowbit(j)}.`);
    }
    snapshot({}, 15, `Only ${touched.length} entries changed. Queries and updates are both O(log n).`);
    return frames;
};
