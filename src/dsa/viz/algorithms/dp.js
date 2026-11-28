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

// More tables for Part VII, added to the same PROGRAMS object
Object.assign(PROGRAMS, {
    houseRobber: {
        title: 'House robber: take a house or skip it',
        defaults: { houses: [2, 7, 9, 3, 1] },
        code: `func rob(_ houses: [Int]) -> Int {
    var best = Array(repeating: 0, count: houses.count + 1)   // best[i]: the most from the first i houses
    for i in 1...houses.count {
        let skip = best[i - 1]                                // leave house i - 1 alone
        let take = (i >= 2 ? best[i - 2] : 0) + houses[i - 1] // rob it, so skip its neighbour
        best[i] = max(skip, take)
    }
    return best[houses.count]
}`,
        * run({ houses }) {
            const best = [0, ...houses.map(() => null)];
            const labels = { rowLabels: ['house', 'best'], colLabels: best.map((_, i) => String(i)) };
            const frame = (current, deps, line, message, path = []) => ({ table: [[null, ...houses], [...best]], ...labels, current: current === null ? null : [1, current], deps, path, line, message });
            yield frame(null, [], 2, 'best[i] is the most you can take from the first i houses. With no houses, that\'s 0.');
            for (let i = 1; i <= houses.length; i += 1) {
                const skip = best[i - 1];
                const take = (i >= 2 ? best[i - 2] : 0) + houses[i - 1];
                best[i] = Math.max(skip, take);
                yield frame(i, [[1, i - 1], ...(i >= 2 ? [[1, i - 2]] : []), [0, i]], 6, `House ${i} holds ${houses[i - 1]}. Skip it: ${skip}. Take it: ${i >= 2 ? best[i - 2] : 0} + ${houses[i - 1]} = ${take}. best[${i}] = ${best[i]}.`);
            }
            const chosen = [];
            for (let i = houses.length; i >= 1;) {
                if (best[i] === best[i - 1]) i -= 1;
                else { chosen.push(i); i -= 2; }
            }
            yield frame(houses.length, [], 8, `The best is ${best[houses.length]}. Walking back through the table (a house was taken wherever best changed) gives houses ${chosen.reverse().join(', ')}: ${chosen.map((i) => houses[i - 1]).join(' + ')}.`, chosen.map((i) => [0, i]));
        },
    },
    minPathSum: {
        title: 'Cheapest path through a grid',
        defaults: { grid: [[2, 3, 1, 4], [1, 7, 1, 2], [5, 2, 3, 1]] },
        code: `func minPathSum(_ grid: [[Int]]) -> Int {
    let rows = grid.count, cols = grid[0].count
    var cost = grid
    for r in 0..<rows {
        for c in 0..<cols where r > 0 || c > 0 {
            let fromAbove = r > 0 ? cost[r - 1][c] : Int.max
            let fromLeft = c > 0 ? cost[r][c - 1] : Int.max
            cost[r][c] = grid[r][c] + min(fromAbove, fromLeft)
        }
    }
    return cost[rows - 1][cols - 1]
}`,
        * run({ grid }) {
            const rows = grid.length;
            const cols = grid[0].length;
            const cost = blank(rows, cols);
            cost[0][0] = grid[0][0];
            const labels = { rowLabels: grid.map((_, r) => String(r)), colLabels: grid[0].map((_, c) => String(c)) };
            yield { table: copy(cost), ...labels, current: [0, 0], deps: [], path: [], line: 3, message: `Moving only right or down. The start costs its own value, ${grid[0][0]}. Each cell will hold the cheapest way to reach it.` };
            for (let r = 0; r < rows; r += 1) {
                for (let c = 0; c < cols; c += 1) {
                    if (r === 0 && c === 0) continue;
                    const above = r > 0 ? cost[r - 1][c] : Infinity;
                    const left = c > 0 ? cost[r][c - 1] : Infinity;
                    cost[r][c] = grid[r][c] + Math.min(above, left);
                    const from = above <= left ? 'above' : 'the left';
                    yield { table: copy(cost), ...labels, current: [r, c], deps: [...(r > 0 ? [[r - 1, c]] : []), ...(c > 0 ? [[r, c - 1]] : [])], path: [], line: 8, message: `${grid[r][c]} + the cheaper way in (${r > 0 && c > 0 ? `${from}, ${Math.min(above, left)}` : `${r > 0 ? 'above' : 'the left'}, the only way`}) = ${cost[r][c]}.` };
                }
            }
            const path = [[rows - 1, cols - 1]];
            for (let [r, c] = [rows - 1, cols - 1]; r > 0 || c > 0;) {
                if (r > 0 && (c === 0 || cost[r - 1][c] <= cost[r][c - 1])) r -= 1; else c -= 1;
                path.unshift([r, c]);
            }
            yield { table: copy(cost), ...labels, current: null, deps: [], path, line: 11, message: `The cheapest path costs ${cost[rows - 1][cols - 1]}. Walking back to whichever neighbour was cheaper traces it: ${path.map(([r, c]) => grid[r][c]).join(' → ')}.` };
        },
    },
    matrixChain: {
        title: 'Matrix chain: the cheapest way to bracket',
        defaults: { dims: [10, 30, 5, 60, 10] },
        code: `func matrixChainCost(_ dims: [Int]) -> Int {        // matrix i is dims[i] × dims[i + 1]
    let n = dims.count - 1
    var cost = Array(repeating: Array(repeating: 0, count: n), count: n)
    for length in 2...n {                           // shorter chains first
        for i in 0...(n - length) {
            let j = i + length - 1
            cost[i][j] = Int.max
            for k in i..<j {                        // split into i...k and k+1...j
                let total = cost[i][k] + cost[k + 1][j] + dims[i] * dims[k + 1] * dims[j + 1]
                cost[i][j] = min(cost[i][j], total)
            }
        }
    }
    return cost[0][n - 1]
}`,
        * run({ dims }) {
            const n = dims.length - 1;
            const cost = blank(n, n);
            const split = blank(n, n);
            for (let i = 0; i < n; i += 1) cost[i][i] = 0;
            const names = Array.from({ length: n }, (_, i) => `A${i + 1}`);
            const labels = { rowLabels: names, colLabels: names };
            yield { table: copy(cost), ...labels, current: null, deps: [], path: [], line: 3, message: `${names.map((name, i) => `${name} is ${dims[i]}×${dims[i + 1]}`).join(', ')}. Each cell holds the fewest multiplications for the chain from its row's matrix to its column's; a single matrix costs 0.` };
            for (let length = 2; length <= n; length += 1) {
                for (let i = 0; i + length - 1 < n; i += 1) {
                    const j = i + length - 1;
                    let best = Infinity;
                    let bestK = i;
                    for (let k = i; k < j; k += 1) {
                        const total = cost[i][k] + cost[k + 1][j] + dims[i] * dims[k + 1] * dims[j + 1];
                        if (total < best) { best = total; bestK = k; }
                    }
                    cost[i][j] = best;
                    split[i][j] = bestK;
                    yield { table: copy(cost), ...labels, current: [i, j], deps: [[i, bestK], [bestK + 1, j]], path: [], line: 10, message: `${names[i]}…${names[j]}: try every split. The best is after ${names[bestK]}: ${cost[i][bestK]} + ${cost[bestK + 1][j]} + ${dims[i]}·${dims[bestK + 1]}·${dims[j + 1]} = ${best}.` };
                }
            }
            const bracket = (i, j) => (i === j ? names[i] : `(${bracket(i, split[i][j])} ${bracket(split[i][j] + 1, j)})`);
            yield { table: copy(cost), ...labels, current: [0, n - 1], deps: [], path: [], line: 14, message: `The whole chain costs ${cost[0][n - 1]} multiplications at best: ${bracket(0, n - 1)}. Ranges were filled shortest first, so every smaller range was ready when needed.` };
        },
    },
    wordBreak: {
        title: 'Word break: can the text be split into words?',
        defaults: { text: 'icecreamcone', words: ['ice', 'cream', 'icecream', 'cone', 'con'] },
        code: `func canSegment(_ text: String, _ words: Set<String>) -> Bool {
    let characters = Array(text)
    var ok = Array(repeating: false, count: characters.count + 1)   // ok[i]: the first i characters split into words
    ok[0] = true
    for end in 1...characters.count {
        for start in 0..<end where ok[start] && words.contains(String(characters[start..<end])) {
            ok[end] = true
            break
        }
    }
    return ok[characters.count]
}`,
        * run({ text, words }) {
            const characters = [...text];
            const dictionary = new Set(words);
            const ok = [true, ...characters.map(() => null)];
            const show = () => [ok.map((value) => (value === null ? null : value ? '✓' : '✗'))];
            const labels = { rowLabels: ['ok'], colLabels: ['∅', ...characters] };
            yield { table: show(), ...labels, current: [0, 0], deps: [], path: [], line: 4, message: `ok[i] says whether the first i characters split into words from {${[...words].sort().join(', ')}}. The empty prefix always does.` };
            for (let end = 1; end <= characters.length; end += 1) {
                let found = null;
                for (let start = 0; start < end; start += 1) {
                    if (ok[start] && dictionary.has(characters.slice(start, end).join(''))) { found = start; break; }
                }
                ok[end] = found !== null;
                yield { table: show(), ...labels, current: [0, end], deps: found === null ? [] : [[0, found]], path: [], line: found === null ? 5 : 7, message: found === null ? `"${characters.slice(0, end).join('')}": no split point leaves a dictionary word at the end. ✗` : `"${characters.slice(0, end).join('')}": ok[${found}] is ✓ and "${characters.slice(found, end).join('')}" is a word. ✓` };
            }
            const path = [];
            if (ok[characters.length]) {
                for (let end = characters.length; end > 0;) {
                    path.unshift([0, end]);
                    let start = 0;
                    while (!(ok[start] && dictionary.has(characters.slice(start, end).join('')))) start += 1;
                    end = start;
                }
            }
            yield { table: show(), ...labels, current: null, deps: [], path, line: 11, message: ok[characters.length] ? `"${text}" can be split. Green marks where words end.` : `"${text}" can't be split into dictionary words.` };
        },
    },
    stockCooldown: {
        title: 'Stocks with a cooldown: three states per day',
        defaults: { prices: [3, 1, 4, 2, 5, 0, 3] },
        code: `func maxProfitWithCooldown(_ prices: [Int]) -> Int {
    var hold = Int.min / 2        // best profit while holding a share
    var sold = 0                  // sold today, so tomorrow must be a rest
    var rest = 0                  // holding nothing and free to buy
    for price in prices {
        let previousSold = sold
        sold = hold + price                     // sell the share we hold
        hold = max(hold, rest - price)          // keep holding, or buy from rest
        rest = max(rest, previousSold)          // keep resting, or finish the cooldown
    }
    return max(sold, rest)
}`,
        * run({ prices }) {
            const columns = prices.length + 1;
            const table = [[null, ...prices], blank(1, columns)[0], blank(1, columns)[0], blank(1, columns)[0]];
            const show = (value) => (value <= -1e9 ? '−∞' : value);
            let hold = -Infinity;
            let sold = 0;
            let rest = 0;
            table[1][0] = show(hold);
            table[2][0] = sold;
            table[3][0] = rest;
            const labels = { rowLabels: ['price', 'hold', 'sold', 'rest'], colLabels: ['start', ...prices.map((_, day) => `d${day}`)] };
            yield { table: copy(table), ...labels, current: null, deps: [], path: [], line: 4, message: 'Three states each day: holding a share, just sold (cooling down), or resting with nothing. Before day 0 you can\'t be holding anything.' };
            for (const [day, price] of prices.entries()) {
                const column = day + 1;
                const previousSold = sold;
                const nextSold = hold + price;
                const nextHold = Math.max(hold, rest - price);
                const nextRest = Math.max(rest, previousSold);
                sold = nextSold;
                hold = nextHold;
                rest = nextRest;
                table[1][column] = show(hold);
                table[2][column] = show(sold);
                table[3][column] = rest;
                yield { table: copy(table), ...labels, current: [2, column], deps: [[1, column - 1], [3, column - 1], [2, column - 1]], path: [], line: 9, message: `Day ${day}, price ${price}. sold = hold + ${price} = ${show(sold)}; hold = max(keep, rest − ${price}) = ${show(hold)}; rest = max(rest, yesterday's sold) = ${rest}.` };
            }
            yield { table: copy(table), ...labels, current: null, deps: [], path: [[2, columns - 1], [3, columns - 1]], line: 11, message: `The answer is the better of ending sold or resting: ${Math.max(sold, rest)}. Each day only looks at the day before, so three variables replace the whole table.` };
        },
    },
});

Object.assign(PROGRAMS, {
    floydWarshall: {
        title: 'Floyd–Warshall: allow one more stop at a time',
        defaults: { nodes: ['A', 'B', 'C', 'D'], edges: [['A', 'B', 3], ['A', 'D', 7], ['B', 'A', 8], ['B', 'C', 2], ['C', 'A', 5], ['C', 'D', 1], ['D', 'A', 2]] },
        code: `func allPairsShortest(_ weights: [[Int?]]) -> [[Int?]] {     // weights[i][j]: the edge i→j, or nil
    let n = weights.count
    var dist = weights
    for i in 0..<n { dist[i][i] = 0 }
    for k in 0..<n {                                  // allow k as a stop on the way
        for i in 0..<n {
            for j in 0..<n {
                if let ik = dist[i][k], let kj = dist[k][j], ik + kj < dist[i][j] ?? .max {
                    dist[i][j] = ik + kj
                }
            }
        }
    }
    return dist
}`,
        * run({ nodes, edges }) {
            const n = nodes.length;
            const index = Object.fromEntries(nodes.map((node, at) => [node, at]));
            const dist = Array.from({ length: n }, () => Array(n).fill(Infinity));
            edges.forEach(([from, to, weight]) => { dist[index[from]][index[to]] = Math.min(dist[index[from]][index[to]], weight); });
            for (let i = 0; i < n; i += 1) dist[i][i] = 0;
            const show = () => dist.map((row) => row.map((value) => (value === Infinity ? '∞' : value)));
            const labels = { rowLabels: nodes.map((node) => `from ${node}`), colLabels: nodes.map((node) => `to ${node}`) };
            yield { table: show(), ...labels, current: null, deps: [], path: [], line: 4, message: 'Start with the direct edges only: ∞ where there is no edge, 0 on the diagonal.' };
            for (let k = 0; k < n; k += 1) {
                const improved = [];
                for (let i = 0; i < n; i += 1) {
                    for (let j = 0; j < n; j += 1) {
                        if (dist[i][k] + dist[k][j] < dist[i][j]) {
                            const old = dist[i][j];
                            dist[i][j] = dist[i][k] + dist[k][j];
                            improved.push([i, j]);
                            yield { table: show(), ...labels, current: [i, j], deps: [[i, k], [k, j]], path: [], line: 9, message: `Stopping at ${nodes[k]}: ${nodes[i]}→${nodes[k]} (${dist[i][k]}) + ${nodes[k]}→${nodes[j]} (${dist[k][j]}) = ${dist[i][j]}, better than ${old === Infinity ? '∞' : old}.` };
                        }
                    }
                }
                yield { table: show(), ...labels, current: null, deps: [], path: improved, line: 5, message: `${nodes[k]} is now allowed as a stop. ${improved.length ? `${improved.length} distance${improved.length === 1 ? '' : 's'} improved (green).` : 'Nothing improved.'}${k + 1 < n ? ` Next, also allow ${nodes[k + 1]}.` : ''}` };
            }
            yield { table: show(), ...labels, current: null, deps: [], path: [], line: 14, message: `Every pair's shortest distance, after allowing each of the ${n} nodes as a stop in turn: O(n³). A negative number on the diagonal would mean a negative cycle.` };
        },
    },
});

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
