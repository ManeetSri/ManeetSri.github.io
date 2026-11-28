// Union-find (disjoint sets) over 0..<count with path compression and union by size.
// Operations: "union a b", "find x", "connected a b". Frames: { parent, size, marks: { index: tone },
// components, result?, line, message }. The view draws `parent` as an array and as a forest.

export const UNION_FIND_CODE = `struct UnionFind {
    private var parent: [Int]
    private var size: [Int]
    init(count: Int) {
        parent = Array(0..<count)
        size = Array(repeating: 1, count: count)
    }
    mutating func find(_ x: Int) -> Int {
        var root = x
        while parent[root] != root { root = parent[root] }   // walk up to the root
        var node = x
        while node != root {                                 // path compression
            let next = parent[node]
            parent[node] = root
            node = next
        }
        return root
    }
    mutating func union(_ a: Int, _ b: Int) -> Bool {
        var rootA = find(a), rootB = find(b)
        if rootA == rootB { return false }                   // already in one set
        if size[rootA] < size[rootB] { swap(&rootA, &rootB) }
        parent[rootB] = rootA                                // smaller tree under the larger
        size[rootA] += size[rootB]
        return true
    }
}`;

const DEFAULT_OPERATIONS = ['union 0 1', 'union 2 3', 'union 4 5', 'union 0 2', 'union 4 0', 'find 3', 'connected 1 5', 'union 1 3'];

export const unionFindFrames = ({ count = 7, operations = DEFAULT_OPERATIONS } = {}) => {
    const parent = Array.from({ length: count }, (_, index) => index);
    const size = Array(count).fill(1);
    let components = count;
    const frames = [];
    const push = (line, message, marks = {}, result) => frames.push({ parent: [...parent], size: [...size], marks, components, result, line, message });
    const pathOf = (x) => {
        const path = [x];
        while (parent[path.at(-1)] !== path.at(-1)) path.push(parent[path.at(-1)]);
        return path;
    };
    // find, with a frame for the walk and another if compression re-points anything
    const find = (x) => {
        const path = pathOf(x);
        const root = path.at(-1);
        push(10, path.length === 1 ? `find(${x}): ${x} is its own parent, so it's a root.` : `find(${x}): walk up ${path.join(' → ')}. The root is ${root}.`, { ...Object.fromEntries(path.map((step) => [step, 'path'])), [root]: 'found' });
        const moved = path.slice(0, -2);
        moved.forEach((step) => { parent[step] = root; });
        if (moved.length) push(14, `Path compression: ${moved.join(', ')} now point${moved.length === 1 ? 's' : ''} straight at ${root}, so the next find from ${moved.length === 1 ? 'it' : 'them'} takes one step.`, { ...Object.fromEntries(moved.map((step) => [step, 'swap'])), [root]: 'found' });
        return root;
    };
    push(5, `${count} elements, each its own set: every element is its own parent (a root).`);
    for (const operation of operations) {
        const [op, ...args] = String(operation).trim().split(/\s+/);
        const [a, b] = args.map(Number);
        if (op === 'find') {
            const root = find(a);
            push(17, `find(${a}) = ${root}.`, { [a]: 'path', [root]: 'found' }, `find(${a}) = ${root}`);
        } else if (op === 'connected') {
            const rootA = find(a);
            const rootB = find(b);
            push(17, rootA === rootB ? `${a} and ${b} have the same root, ${rootA}: they're connected.` : `${a}'s root is ${rootA} and ${b}'s is ${rootB}: different sets.`, { [a]: 'path', [b]: 'path', [rootA]: 'found', [rootB]: 'found' }, `connected(${a}, ${b}) = ${rootA === rootB}`);
        } else if (op === 'union') {
            let rootA = find(a);
            let rootB = find(b);
            if (rootA === rootB) {
                push(21, `union(${a}, ${b}): both are already in the set rooted at ${rootA}. Nothing to do: return false.`, { [a]: 'path', [b]: 'path', [rootA]: 'found' }, `union(${a}, ${b}) = false`);
                continue;
            }
            if (size[rootA] < size[rootB]) [rootA, rootB] = [rootB, rootA];
            parent[rootB] = rootA;
            size[rootA] += size[rootB];
            components -= 1;
            push(23, `union(${a}, ${b}): the set rooted at ${rootB} (size ${size[rootB]}) goes under ${rootA}${size[rootA] - size[rootB] > size[rootB] ? ', the bigger one' : size[rootA] - size[rootB] === size[rootB] ? ' (equal sizes: either way is fine)' : ''}. ${components} set${components === 1 ? '' : 's'} left.`, { [rootB]: 'swap', [rootA]: 'found' }, `union(${a}, ${b}) = true`);
        } else {
            throw new Error(`Union-find can't "${op}" (use union, find or connected)`);
        }
    }
    push(27, `${components} set${components === 1 ? '' : 's'}. With both tricks, each operation costs O(α(n)): at most 4 for any n you'll ever meet.`);
    return frames;
};
