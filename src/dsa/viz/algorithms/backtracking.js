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
