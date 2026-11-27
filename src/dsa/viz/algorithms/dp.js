// Dynamic-programming tables filled cell by cell. Frame: { table: rows of values or null, rowLabels,
// colLabels, current: [r, c] | null, deps: [[r, c]], path: [[r, c]], line, message }.

const blank = (rows, cols) => Array.from({ length: rows }, () => Array(cols).fill(null));
const copy = (table) => table.map((row) => [...row]);

const PROGRAMS = {
    lcs: {
        title: 'Longest common subsequence',
        defaults: { a: 'ABCBDAB', b: 'BDCABA' },
        code: `func lcs(_ a: [Character], _ b: [Character]) -> Int {
    var table = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
    for i in 1...a.count {
        for j in 1...b.count {
            if a[i - 1] == b[j - 1] {
                table[i][j] = table[i - 1][j - 1] + 1
            } else {
                table[i][j] = max(table[i - 1][j], table[i][j - 1])
            }
        }
    }
    return table[a.count][b.count]
}`,
        * run({ a, b }) {
            const x = [...a];
            const y = [...b];
            const table = blank(x.length + 1, y.length + 1);
            for (let i = 0; i <= x.length; i += 1) table[i][0] = 0;
            for (let j = 0; j <= y.length; j += 1) table[0][j] = 0;
            const labels = { rowLabels: ['∅', ...x], colLabels: ['∅', ...y] };
            yield { table: copy(table), ...labels, current: null, deps: [], path: [], line: 2, message: 'Row and column 0 are empty prefixes: their LCS is 0.' };
            for (let i = 1; i <= x.length; i += 1) {
                for (let j = 1; j <= y.length; j += 1) {
                    const match = x[i - 1] === y[j - 1];
                    table[i][j] = match ? table[i - 1][j - 1] + 1 : Math.max(table[i - 1][j], table[i][j - 1]);
                    yield {
                        table: copy(table), ...labels, current: [i, j],
                        deps: match ? [[i - 1, j - 1]] : [[i - 1, j], [i, j - 1]],
                        path: [],
                        line: match ? 6 : 8,
                        message: match ? `${x[i - 1]} = ${y[j - 1]}: extend the diagonal, ${table[i - 1][j - 1]} + 1 = ${table[i][j]}.` : `${x[i - 1]} ≠ ${y[j - 1]}: take the better of above (${table[i - 1][j]}) and left (${table[i][j - 1]}).`,
                    };
                }
            }
            // Walk back to recover one longest subsequence
            const path = [];
            const letters = [];
            let i = x.length;
            let j = y.length;
            while (i > 0 && j > 0) {
                path.push([i, j]);
                if (x[i - 1] === y[j - 1]) {
                    letters.unshift(x[i - 1]);
                    i -= 1;
                    j -= 1;
                } else if (table[i - 1][j] >= table[i][j - 1]) i -= 1;
                else j -= 1;
            }
            yield { table: copy(table), ...labels, current: null, deps: [], path, line: 12, message: `LCS length ${table[x.length][y.length]}. Walking back through the matches spells "${letters.join('')}".` };
        },
    },
    editDistance: {
        title: 'Edit distance',
        defaults: { a: 'kitten', b: 'sitting' },
        code: `func editDistance(_ a: [Character], _ b: [Character]) -> Int {
    var table = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
    for i in 0...a.count { table[i][0] = i }
    for j in 0...b.count { table[0][j] = j }
    for i in 1...a.count {
        for j in 1...b.count {
            if a[i - 1] == b[j - 1] {
                table[i][j] = table[i - 1][j - 1]
            } else {
                table[i][j] = 1 + min(table[i - 1][j - 1], table[i - 1][j], table[i][j - 1])
            }
        }
    }
    return table[a.count][b.count]
}`,
        * run({ a, b }) {
            const x = [...a];
            const y = [...b];
            const table = blank(x.length + 1, y.length + 1);
            for (let i = 0; i <= x.length; i += 1) table[i][0] = i;
            for (let j = 0; j <= y.length; j += 1) table[0][j] = j;
            const labels = { rowLabels: ['∅', ...x], colLabels: ['∅', ...y] };
            yield { table: copy(table), ...labels, current: null, deps: [], path: [], line: 4, message: 'Turning a prefix into the empty string takes as many deletions as it has letters, and the other way round.' };
            for (let i = 1; i <= x.length; i += 1) {
                for (let j = 1; j <= y.length; j += 1) {
                    if (x[i - 1] === y[j - 1]) {
                        table[i][j] = table[i - 1][j - 1];
                        yield { table: copy(table), ...labels, current: [i, j], deps: [[i - 1, j - 1]], path: [], line: 8, message: `${x[i - 1]} = ${y[j - 1]}: no edit needed, copy the diagonal (${table[i][j]}).` };
                    } else {
                        const options = { replace: table[i - 1][j - 1], delete: table[i - 1][j], insert: table[i][j - 1] };
                        const [best] = Object.entries(options).sort((p, q) => p[1] - q[1]);
                        table[i][j] = 1 + best[1];
                        yield { table: copy(table), ...labels, current: [i, j], deps: [[i - 1, j - 1], [i - 1, j], [i, j - 1]], path: [], line: 10, message: `${x[i - 1]} ≠ ${y[j - 1]}: 1 + the cheapest of replace (${options.replace}), delete (${options.delete}) and insert (${options.insert}) = ${table[i][j]}.` };
                    }
                }
            }
            yield { table: copy(table), ...labels, current: [x.length, y.length], deps: [], path: [], line: 14, message: `"${a}" becomes "${b}" in ${table[x.length][y.length]} edits.` };
        },
    },
    knapsack: {
        title: '0/1 knapsack',
        defaults: { weights: [1, 3, 4, 5], values: [1, 4, 5, 7], capacity: 7 },
        code: `func knapsack(_ weights: [Int], _ values: [Int], _ capacity: Int) -> Int {
    let n = weights.count
    var table = Array(repeating: Array(repeating: 0, count: capacity + 1), count: n + 1)
    for item in 1...n {
        for room in 0...capacity {
            table[item][room] = table[item - 1][room]                 // skip the item
            if weights[item - 1] <= room {                             // or take it
                table[item][room] = max(table[item][room], table[item - 1][room - weights[item - 1]] + values[item - 1])
            }
        }
    }
    return table[n][capacity]
}`,
        * run({ weights, values, capacity }) {
            const n = weights.length;
            const table = blank(n + 1, capacity + 1);
            for (let room = 0; room <= capacity; room += 1) table[0][room] = 0;
            const labels = { rowLabels: ['none', ...weights.map((w, index) => `w${w} v${values[index]}`)], colLabels: Array.from({ length: capacity + 1 }, (_, room) => String(room)) };
            yield { table: copy(table), ...labels, current: null, deps: [], path: [], line: 3, message: 'Rows are "using the first i items", columns are the room left. With no items, the value is 0.' };
            for (let item = 1; item <= n; item += 1) {
                for (let room = 0; room <= capacity; room += 1) {
                    const skip = table[item - 1][room];
                    const fits = weights[item - 1] <= room;
                    const take = fits ? table[item - 1][room - weights[item - 1]] + values[item - 1] : null;
                    table[item][room] = fits ? Math.max(skip, take) : skip;
                    yield {
                        table: copy(table), ...labels, current: [item, room],
                        deps: fits ? [[item - 1, room], [item - 1, room - weights[item - 1]]] : [[item - 1, room]],
                        path: [],
                        line: fits ? 8 : 6,
                        message: fits ? `Room ${room}: skip gives ${skip}, take gives ${take}. Best ${table[item][room]}.` : `Room ${room}: the item (weight ${weights[item - 1]}) doesn't fit. Keep ${skip}.`,
                    };
                }
            }
            yield { table: copy(table), ...labels, current: [n, capacity], deps: [], path: [], line: 12, message: `The best value that fits in ${capacity} is ${table[n][capacity]}.` };
        },
    },
    coinChange: {
        title: 'Fewest coins for an amount',
        defaults: { coins: [1, 3, 4], amount: 6 },
        code: `func fewestCoins(_ coins: [Int], _ amount: Int) -> Int? {
    var best = [0] + Array(repeating: Int.max, count: amount)
    for total in 1...amount {
        for coin in coins where coin <= total && best[total - coin] != .max {
            best[total] = min(best[total], best[total - coin] + 1)
        }
    }
    return best[amount] == .max ? nil : best[amount]
}`,
        * run({ coins, amount }) {
            const best = [0, ...Array(amount).fill(null)];
            const frame = (current, deps, line, message) => ({ table: [best.map((value) => (value === null ? null : value === Infinity ? '∞' : value))], rowLabels: ['coins'], colLabels: Array.from({ length: amount + 1 }, (_, total) => String(total)), current: current === null ? null : [0, current], deps: deps.map((total) => [0, total]), path: [], line, message });
            yield frame(null, [], 2, 'best[0] = 0: no coins make 0. Everything else starts unknown.');
            for (let total = 1; total <= amount; total += 1) {
                best[total] = Infinity;
                const used = [];
                for (const coin of coins) {
                    if (coin > total || best[total - coin] === Infinity) continue;
                    used.push(total - coin);
                    best[total] = Math.min(best[total], best[total - coin] + 1);
                }
                yield frame(total, used, 5, `best[${total}] = 1 + the best of ${used.map((from) => `best[${from}]`).join(', ') || 'nothing'} = ${best[total] === Infinity ? '∞' : best[total]}.`);
            }
            yield frame(amount, [], 8, `${amount} needs ${best[amount]} coin${best[amount] === 1 ? '' : 's'}. Greedy (biggest first) would use ${greedyCount(coins, amount)}: DP finds the true minimum.`);
        },
    },
    uniquePaths: {
        title: 'Counting paths through a grid',
        defaults: { rows: 4, cols: 5 },
        code: `func uniquePaths(_ rows: Int, _ cols: Int) -> Int {
    var ways = Array(repeating: Array(repeating: 1, count: cols), count: rows)
    for r in 1..<rows {
        for c in 1..<cols {
            ways[r][c] = ways[r - 1][c] + ways[r][c - 1]
        }
    }
    return ways[rows - 1][cols - 1]
}`,
        * run({ rows, cols }) {
            const table = blank(rows, cols);
            for (let r = 0; r < rows; r += 1) table[r][0] = 1;
            for (let c = 0; c < cols; c += 1) table[0][c] = 1;
            const labels = { rowLabels: Array.from({ length: rows }, (_, r) => String(r)), colLabels: Array.from({ length: cols }, (_, c) => String(c)) };
            yield { table: copy(table), ...labels, current: null, deps: [], path: [], line: 2, message: 'Moving only right or down, there is exactly one way to reach any cell in the top row or left column.' };
            for (let r = 1; r < rows; r += 1) {
                for (let c = 1; c < cols; c += 1) {
                    table[r][c] = table[r - 1][c] + table[r][c - 1];
                    yield { table: copy(table), ...labels, current: [r, c], deps: [[r - 1, c], [r, c - 1]], path: [], line: 5, message: `From above (${table[r - 1][c]}) or from the left (${table[r][c - 1]}): ${table[r][c]} ways.` };
                }
            }
            yield { table: copy(table), ...labels, current: [rows - 1, cols - 1], deps: [], path: [], line: 8, message: `${table[rows - 1][cols - 1]} paths in total, from ${rows * cols} cells of work instead of trying every path.` };
        },
    },
    lis: {
        title: 'Longest increasing subsequence, O(n²)',
        defaults: { items: [10, 9, 2, 5, 3, 7, 101, 18] },
        code: `func longestIncreasing(_ items: [Int]) -> Int {
    var length = Array(repeating: 1, count: items.count)
    for i in items.indices {
        for j in 0..<i where items[j] < items[i] {
            length[i] = max(length[i], length[j] + 1)
        }
    }
    return length.max() ?? 0
}`,
        * run({ items }) {
            const length = items.map(() => null);
            const frame = (current, deps, line, message) => ({ table: [[...items], length.map((value) => value)], rowLabels: ['items', 'length'], colLabels: items.map((_, index) => String(index)), current: current === null ? null : [1, current], deps: deps.map((index) => [1, index]), path: [], line, message });
            yield frame(null, [], 2, 'length[i] will be the longest increasing subsequence ending exactly at index i.');
            for (let i = 0; i < items.length; i += 1) {
                length[i] = 1;
                const smaller = [];
                for (let j = 0; j < i; j += 1) {
                    if (items[j] < items[i]) {
                        smaller.push(j);
                        length[i] = Math.max(length[i], length[j] + 1);
                    }
                }
                yield frame(i, smaller, 5, smaller.length ? `${items[i]} can extend runs ending at ${smaller.map((j) => items[j]).join(', ')}: length ${length[i]}.` : `Nothing before ${items[i]} is smaller: a run of 1.`);
            }
            yield frame(null, [], 8, `The longest increasing subsequence has length ${Math.max(...length)}.`);
        },
    },
};

const greedyCount = (coins, amount) => {
    let left = amount;
    let count = 0;
    for (const coin of [...coins].sort((a, b) => b - a)) {
        count += Math.floor(left / coin);
        left %= coin;
    }
    return left === 0 ? count : 'no answer';
};

export const DP_PROGRAMS = Object.keys(PROGRAMS);

export const dpProgram = (name) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown DP program "${name}"`);
    return program;
};

export const dpFrames = (name, input = {}) => [...dpProgram(name).run({ ...dpProgram(name).defaults, ...input })];
