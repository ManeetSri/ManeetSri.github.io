// Backtracking as frames: choose, explore, unchoose.

export const QUEENS_CODE = `func solveQueens(_ n: Int) -> [[Int]] {
    var solutions: [[Int]] = []
    var columns: [Int] = []          // columns[row] is the queen's column in that row
    func safe(_ row: Int, _ col: Int) -> Bool {
        for (r, c) in columns.enumerated() where c == col || abs(c - col) == row - r {
            return false
        }
        return true
    }
    func place(_ row: Int) {
        if row == n { solutions.append(columns); return }
        for col in 0..<n where safe(row, col) {
            columns.append(col)      // choose
            place(row + 1)           // explore
            columns.removeLast()     // unchoose
        }
    }
    place(0)
    return solutions
}`;

// Frames: { n, queens: [col per placed row], trying: [row, col] | null, attackers: [[r, c]], solutions, line, message }
export const queensFrames = ({ n = 4, all = false } = {}) => {
    const frames = [];
    const columns = [];
    let solutions = 0;
    const snapshot = (trying, attackers, line, message) => frames.push({ n, queens: [...columns], trying, attackers, solutions, line, message });
    const conflicts = (row, col) => columns.map((c, r) => [r, c]).filter(([r, c]) => c === col || Math.abs(c - col) === row - r);
    let done = false;
    const place = (row) => {
        if (done) return;
        if (row === n) {
            solutions += 1;
            snapshot(null, [], 11, `All ${n} queens placed: solution ${solutions}.${all ? ' Keep searching for more.' : ''}`);
            if (!all) done = true;
            return;
        }
        for (let col = 0; col < n && !done; col += 1) {
            const attackers = conflicts(row, col);
            if (attackers.length) {
                snapshot([row, col], attackers, 5, `Row ${row}, column ${col} is attacked by the highlighted queen${attackers.length > 1 ? 's' : ''}. Try the next column.`);
                continue;
            }
            columns.push(col);
            snapshot(null, [], 13, `Row ${row}, column ${col} is safe: place a queen and move to row ${row + 1}.`);
            place(row + 1);
            if (done) return;
            columns.pop();
            snapshot(null, [], 15, `Nothing worked below row ${row}: remove the queen from column ${col} and try further right. That's backtracking.`);
        }
    };
    snapshot(null, [], 1, `Place ${n} queens so none attack each other: one per row, trying columns left to right.`);
    place(0);
    if (!done) snapshot(null, [], 19, `Search finished: ${solutions} solution${solutions === 1 ? '' : 's'} for n = ${n}.`);
    return frames;
};

export const SUBSETS_CODE = `func subsets(_ items: [Int]) -> [[Int]] {
    var result: [[Int]] = []
    var chosen: [Int] = []
    func explore(_ index: Int) {
        if index == items.count { result.append(chosen); return }
        chosen.append(items[index])      // include items[index]
        explore(index + 1)
        chosen.removeLast()              // or leave it out
        explore(index + 1)
    }
    explore(0)
    return result
}`;

// A decision tree: each level decides one item. Frames: { nodes: { id: { label, children, leaf } }, root, path, results, line, message }
export const subsetsFrames = ({ items = [1, 2, 3] } = {}) => {
    const nodes = {};
    let nextId = 0;
    const frames = [];
    const results = [];
    const path = [];
    const add = (label, parent) => {
        const id = String(nextId);
        nextId += 1;
        nodes[id] = { value: label, children: [], leaf: false };
        if (parent !== null) nodes[parent].children.push(id);
        return id;
    };
    const snapshot = (line, message) => frames.push({ root: '0', nodes: JSON.parse(JSON.stringify(nodes)), path: [...path], results: [...results], line, message });
    const chosen = [];
    const explore = (index, id) => {
        path.push(id);
        if (index === items.length) {
            nodes[id].leaf = true;
            results.push([...chosen]);
            snapshot(5, `Every item is decided: record [${chosen.join(', ')}].`);
            path.pop();
            return;
        }
        chosen.push(items[index]);
        const withId = add(`[${chosen.join(',')}]`, id);
        snapshot(6, `Include ${items[index]}.`);
        explore(index + 1, withId);
        chosen.pop();
        const withoutId = add(`[${chosen.join(',')}]`, id);
        snapshot(8, `Now leave ${items[index]} out instead.`);
        explore(index + 1, withoutId);
        path.pop();
    };
    add('[]', null);
    snapshot(11, `Each level decides one item: in or out. ${items.length} items give 2^${items.length} = ${2 ** items.length} leaves.`);
    explore(0, '0');
    snapshot(12, `All ${results.length} subsets, one per leaf.`);
    return frames;
};

export const PERMUTATIONS_CODE = `func permutations(_ items: [Int]) -> [[Int]] {
    var result: [[Int]] = []
    var chosen: [Int] = []
    var used = Array(repeating: false, count: items.count)
    func explore() {
        if chosen.count == items.count { result.append(chosen); return }
        for i in items.indices where !used[i] {
            used[i] = true
            chosen.append(items[i])          // choose
            explore()                        // explore
            chosen.removeLast()              // unchoose
            used[i] = false
        }
    }
    explore()
    return result
}`;

export const COMBINATION_SUM_CODE = `func combinationSum(_ candidates: [Int], _ target: Int) -> [[Int]] {
    let sorted = candidates.sorted()
    var result: [[Int]] = []
    var chosen: [Int] = []
    func explore(_ start: Int, _ remaining: Int) {
        if remaining == 0 { result.append(chosen); return }
        for i in start..<sorted.count {
            if sorted[i] > remaining { break }       // sorted, so every later candidate is too big
            chosen.append(sorted[i])
            explore(i, remaining - sorted[i])        // i, not i + 1: a number can be reused
            chosen.removeLast()
        }
    }
    explore(0, target)
    return result
}`;

// Shared bookkeeping for decision trees: nodes { id: { value, children, leaf, pruned } }
const decisionTree = () => {
    const nodes = {};
    let nextId = 0;
    const add = (label, parent, extra = {}) => {
        const id = String(nextId);
        nextId += 1;
        nodes[id] = { value: label, children: [], leaf: false, ...extra };
        if (parent !== null) nodes[parent].children.push(id);
        return id;
    };
    return { nodes, add };
};

export const permutationsFrames = ({ items = [1, 2, 3] } = {}) => {
    const { nodes, add } = decisionTree();
    const frames = [];
    const results = [];
    const path = [];
    const chosen = [];
    const used = items.map(() => false);
    const snapshot = (line, message) => frames.push({ root: '0', nodes: JSON.parse(JSON.stringify(nodes)), path: [...path], results: [...results], line, message });
    const explore = (id) => {
        path.push(id);
        if (chosen.length === items.length) {
            nodes[id].leaf = true;
            results.push([...chosen]);
            snapshot(6, `All ${items.length} placed: record [${chosen.join(', ')}].`);
            path.pop();
            return;
        }
        for (let i = 0; i < items.length; i += 1) {
            if (used[i]) continue;
            used[i] = true;
            chosen.push(items[i]);
            const child = add(`[${chosen.join(',')}]`, id);
            snapshot(9, chosen.length > 1 ? `Choose ${items[i]}, skipping the items already used.` : `Choose ${items[i]} first.`);
            explore(child);
            chosen.pop();
            used[i] = false;
            snapshot(12, `Unchoose ${items[i]}: it's free again for the next branch.`);
        }
        path.pop();
    };
    add('[]', null);
    const factorial = items.reduce((product, _, index) => product * (index + 1), 1);
    snapshot(15, `Each level picks one unused item. ${items.length} items give ${items.length}! = ${factorial} leaves.`);
    explore('0');
    snapshot(16, `All ${results.length} permutations, one per leaf.`);
    return frames;
};

export const combinationSumFrames = ({ candidates = [2, 3, 5], target = 7 } = {}) => {
    const sorted = [...candidates].sort((a, b) => a - b);
    const { nodes, add } = decisionTree();
    const frames = [];
    const results = [];
    const path = [];
    const chosen = [];
    const snapshot = (line, message) => frames.push({ root: '0', nodes: JSON.parse(JSON.stringify(nodes)), path: [...path], results: [...results], line, message });
    const explore = (start, remaining, id) => {
        path.push(id);
        if (remaining === 0) {
            nodes[id].leaf = true;
            results.push([...chosen]);
            snapshot(6, `The sum is exactly ${target}: record [${chosen.join(', ')}].`);
            path.pop();
            return;
        }
        for (let i = start; i < sorted.length; i += 1) {
            if (sorted[i] > remaining) {
                add(`+${sorted[i]}`, id, { pruned: true });
                snapshot(8, `${sorted[i]} is more than the ${remaining} left. The candidates are sorted, so everything after it is too: stop this branch.`);
                break;
            }
            chosen.push(sorted[i]);
            const child = add(`[${chosen.join(',')}]`, id);
            snapshot(9, `Take ${sorted[i]}: ${remaining - sorted[i]} left. Its children start at ${sorted[i]} again, because numbers can repeat.`);
            explore(i, remaining - sorted[i], child);
            chosen.pop();
        }
        path.pop();
    };
    add('[]', null);
    snapshot(14, `Find every multiset of {${sorted.join(', ')}} that sums to ${target}. Starting each loop at the current index stops [2,3] and [3,2] both appearing.`);
    explore(0, target, '0');
    snapshot(15, `${results.length} combination${results.length === 1 ? '' : 's'}: ${results.map((r) => `[${r.join(',')}]`).join(' ')}. Red branches were cut before they were explored.`);
    return frames;
};
