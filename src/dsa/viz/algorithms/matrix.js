// Grid programs for the matrix visualiser, matching the M19 lessons.
// Each frame: { grids: [{ label, cells, marks: { 'r,c': tone }, order?: { 'r,c': n }, bounds?, cellsAre? }],
//   output?, vars, line, message }. Tones: current, done, swap, kept, near. `cellsAre: 'life'` draws 0/1 as dead/alive.

const copy = (grid) => grid.map((row) => [...row]);
const key = (r, c) => `${r},${c}`;

const spiral = {
    title: 'Spiral order with four boundaries',
    defaults: { grid: [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]] },
    code: `func spiralOrder(_ grid: [[Int]]) -> [Int] {
    var result: [Int] = []
    guard let firstRow = grid.first else { return result }
    var top = 0, bottom = grid.count - 1
    var left = 0, right = firstRow.count - 1
    while top <= bottom && left <= right {
        for c in left...right { result.append(grid[top][c]) }
        top += 1
        if top <= bottom {
            for r in top...bottom { result.append(grid[r][right]) }
        }
        right -= 1
        if top <= bottom {
            for c in stride(from: right, through: left, by: -1) { result.append(grid[bottom][c]) }
            bottom -= 1
        }
        if left <= right {
            for r in stride(from: bottom, through: top, by: -1) { result.append(grid[r][left]) }
            left += 1
        }
    }
    return result
}`,
    * run({ grid }) {
        const result = [];
        const order = {};
        let top = 0;
        let bottom = grid.length - 1;
        let left = 0;
        let right = (grid[0]?.length ?? 0) - 1;
        const frame = (walked, line, message) => {
            const marks = Object.fromEntries(Object.keys(order).map((cell) => [cell, 'done']));
            walked.forEach(([r, c]) => { marks[key(r, c)] = 'current'; });
            return { grids: [{ label: 'grid', cells: grid, marks, order: { ...order }, bounds: { top, bottom, left, right } }], output: [...result], vars: { top, bottom, left, right }, line, message };
        };
        const visit = (cells) => cells.forEach(([r, c]) => { result.push(grid[r][c]); order[key(r, c)] = result.length; });
        const range = (from, to) => (from <= to ? Array.from({ length: to - from + 1 }, (_, index) => from + index) : Array.from({ length: from - to + 1 }, (_, index) => from - index));
        const list = (cells) => cells.map(([r, c]) => grid[r][c]).join(' ');
        yield frame([], 5, 'The shaded rectangle is everything not yet visited: rows top…bottom, columns left…right. Each walk uses up one edge of it.');
        while (top <= bottom && left <= right) {
            let cells = range(left, right).map((c) => [top, c]);
            visit(cells);
            top += 1;
            yield frame(cells, 8, `Top row, left to right: ${list(cells)}. That row is used up, so top = ${top}.`);
            cells = top <= bottom ? range(top, bottom).map((r) => [r, right]) : [];
            visit(cells);
            right -= 1;
            yield frame(cells, cells.length ? 12 : 9, cells.length ? `Right column, downwards: ${list(cells)}. right = ${right}.` : `top > bottom: no rows are left, so the right column has nothing to visit. right = ${right}.`);
            if (top <= bottom) {
                cells = right >= left ? range(right, left).map((c) => [bottom, c]) : [];
                visit(cells);
                bottom -= 1;
                yield frame(cells, 15, `${cells.length ? `Bottom row, right to left: ${list(cells)}.` : 'No columns are left, so the bottom-row walk is empty.'} bottom = ${bottom}.`);
            } else {
                yield frame([], 13, 'top > bottom: the top-row walk took the last row. Walking the bottom row now would visit it a second time, so skip it.');
            }
            if (left <= right) {
                cells = bottom >= top ? range(bottom, top).map((r) => [r, left]) : [];
                visit(cells);
                left += 1;
                yield frame(cells, 19, `${cells.length ? `Left column, upwards: ${list(cells)}.` : 'No rows are left, so the left-column walk is empty.'} left = ${left}.`);
            } else {
                yield frame([], 17, 'left > right: no columns are left, so skip the left column.');
            }
        }
        yield frame([], 22, `The rectangle is empty. Every cell was visited once: ${result.join(' ')}.`);
    },
};

const rotate = {
    title: 'Rotating a square grid: transpose, then reverse each row',
    defaults: { grid: [[1, 2, 3], [4, 5, 6], [7, 8, 9]] },
    code: `func rotateClockwise(_ grid: inout [[Int]]) {
    let n = grid.count
    for r in 0..<n {
        for c in (r + 1)..<n {           // only cells above the main diagonal
            let saved = grid[r][c]
            grid[r][c] = grid[c][r]
            grid[c][r] = saved
        }
    }
    for r in 0..<n {
        grid[r].reverse()
    }
}`,
    * run({ grid }) {
        const cells = copy(grid);
        const n = cells.length;
        const diagonal = Object.fromEntries(cells.map((_, index) => [key(index, index), 'kept']));
        const frame = (marks, line, message) => ({ grids: [{ label: 'grid', cells: copy(cells), marks: { ...marks } }], line, message });
        yield frame(diagonal, 2, 'Step 1 is a transpose: flip over the main diagonal (green), which stays put.');
        for (let r = 0; r < n; r += 1) {
            for (let c = r + 1; c < n; c += 1) {
                [cells[r][c], cells[c][r]] = [cells[c][r], cells[r][c]];
                yield frame({ ...diagonal, [key(r, c)]: 'swap', [key(c, r)]: 'swap' }, 7, `Swap (${r}, ${c}) with its mirror (${c}, ${r}): ${cells[c][r]} ↔ ${cells[r][c]}. Only cells above the diagonal start a swap, or each pair would swap back.`);
            }
        }
        yield frame({}, 9, `Transposed: row r is now what column r was. ${(n * (n - 1)) / 2} swaps.`);
        for (let r = 0; r < n; r += 1) {
            cells[r].reverse();
            yield frame(Object.fromEntries(cells[r].map((_, c) => [key(r, c), 'current'])), 11, `Step 2: reverse row ${r}, giving ${cells[r].join(', ')}.`);
        }
        yield frame({}, 13, 'A clockwise quarter turn, in place: O(n²) time and O(1) extra space.');
    },
};

const MOVES = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]];

const life = {
    title: 'Game of Life: one generation from a copy',
    defaults: { grid: [[0, 1, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0], [1, 1, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], generations: 4 },
    code: `let moves = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]

func step(_ board: [[Int]]) -> [[Int]] {
    let rows = board.count
    let columns = board[0].count
    var next = board
    for r in 0..<rows {
        for c in 0..<columns {
            var alive = 0
            for (dr, dc) in moves {
                let nr = r + dr
                let nc = c + dc
                if nr >= 0 && nr < rows && nc >= 0 && nc < columns {
                    alive += board[nr][nc]        // always the old board
                }
            }
            next[r][c] = alive == 3 || (board[r][c] == 1 && alive == 2) ? 1 : 0
        }
    }
    return next
}`,
    * run({ grid, generations }) {
        const rows = grid.length;
        const columns = grid[0]?.length ?? 0;
        const neighbours = (board, r, c) => MOVES.map(([dr, dc]) => [r + dr, c + dc]).filter(([nr, nc]) => nr >= 0 && nr < rows && nc >= 0 && nc < columns);
        const nextOf = (board) => board.map((row, r) => row.map((value, c) => {
            const alive = neighbours(board, r, c).reduce((sum, [nr, nc]) => sum + board[nr][nc], 0);
            return alive === 3 || (value === 1 && alive === 2) ? 1 : 0;
        }));
        const board = copy(grid);
        const next = copy(grid);
        // Cells of `next` not decided yet still hold the copied old value, so they're drawn faded
        const undecided = (fromR, fromC) => Object.fromEntries(board.flatMap((row, r) => row.flatMap((_, c) => (r > fromR || (r === fromR && c >= fromC) ? [[key(r, c), 'pending']] : []))));
        yield { grids: [{ label: 'board (now)', cells: copy(board), marks: {}, cellsAre: 'life' }, { label: 'next', cells: copy(next), marks: undecided(0, 0), cellsAre: 'life' }], line: 6, message: 'Count each cell’s live neighbours on the old board and write the verdict into a copy, so no update can disturb a count. Faded cells of next aren’t decided yet.' };
        for (let r = 0; r < rows; r += 1) {
            for (let c = 0; c < columns; c += 1) {
                const around = neighbours(board, r, c);
                const alive = around.reduce((sum, [nr, nc]) => sum + board[nr][nc], 0);
                const was = board[r][c];
                next[r][c] = alive === 3 || (was === 1 && alive === 2) ? 1 : 0;
                // Dead cells with fewer than 2 live neighbours stay dead without a frame of their own
                if (was === 0 && alive < 2) continue;
                const verdict = was === 1
                    ? (next[r][c] === 1 ? `alive with ${alive}: it survives.` : `alive with ${alive}: it dies of ${alive < 2 ? 'loneliness' : 'overcrowding'}.`)
                    : (next[r][c] === 1 ? 'dead with exactly 3: it’s born.' : `dead with ${alive}: it stays dead (birth needs exactly 3).`);
                const near = Object.fromEntries(around.map(([nr, nc]) => [key(nr, nc), 'near']));
                yield {
                    grids: [
                        { label: 'board (now)', cells: copy(board), marks: { ...near, [key(r, c)]: 'current' }, cellsAre: 'life' },
                        { label: 'next', cells: copy(next), marks: { ...undecided(r, c + 1), [key(r, c)]: 'current' }, cellsAre: 'life' },
                    ],
                    vars: { r, c, alive },
                    line: 17,
                    message: `(${r}, ${c}) is ${verdict}`,
                };
            }
        }
        yield { grids: [{ label: 'board (now)', cells: copy(board), marks: {}, cellsAre: 'life' }, { label: 'next', cells: copy(next), marks: {}, cellsAre: 'life' }], line: 20, message: 'Generation 1 done. Dead cells with fewer than 2 live neighbours were skipped here: they can only stay dead.' };
        let current = next;
        for (let generation = 2; generation <= generations; generation += 1) {
            current = nextOf(current);
            yield { grids: [{ label: `generation ${generation}`, cells: copy(current), marks: {}, cellsAre: 'life' }], line: 20, message: generation === generations ? `Generation ${generation}. Each generation is O(rows × columns) time, plus the copy's space.` : `Generation ${generation}, computed the same way.` };
        }
    },
};

const PROGRAMS = { spiral, rotate, life };

export const MATRIX_PROGRAMS = Object.keys(PROGRAMS);

export const matrixProgram = (name) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown matrix program "${name}" (known: ${MATRIX_PROGRAMS.join(', ')})`);
    return program;
};

export const matrixFrames = (name, input = {}) => {
    const program = matrixProgram(name);
    return [...program.run({ ...program.defaults, ...input })];
};
