// Generated from src/dsa/content/lessons/fenwick/bit-2d.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A 2D Fenwick tree: point additions and rectangle sums on a grid, 1-indexed inside
struct Fenwick2D {
    private var tree: [[Int]]
    let rows: Int
    let columns: Int

    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        tree = Array(repeating: Array(repeating: 0, count: columns + 1), count: rows + 1)
    }

    /// Adds delta to the cell (row, column), both 0-indexed.
    mutating func add(_ delta: Int, row: Int, column: Int) {
        var i = row + 1
        while i <= rows {
            var j = column + 1
            while j <= columns {                  // the 1D update, once per row-range i covers
                tree[i][j] += delta
                j += j & -j
            }
            i += i & -i
        }
    }

    /// The sum of every cell in rows 0..<row and columns 0..<column.
    func prefixSum(rows row: Int, columns column: Int) -> Int {
        var total = 0
        var i = row
        while i > 0 {
            var j = column
            while j > 0 {                         // the 1D query, once per row-range
                total += tree[i][j]
                j -= j & -j
            }
            i -= i & -i
        }
        return total
    }

    /// The sum of the rectangle from (top, left) to (bottom, right), inclusive.
    func sum(top: Int, left: Int, bottom: Int, right: Int) -> Int {
        prefixSum(rows: bottom + 1, columns: right + 1)
            - prefixSum(rows: top, columns: right + 1)
            - prefixSum(rows: bottom + 1, columns: left)
            + prefixSum(rows: top, columns: left)
    }
}

var field = Fenwick2D(rows: 4, columns: 5)
let start = [
    [3, 0, 1, 4, 2],
    [5, 6, 3, 2, 1],
    [1, 2, 0, 1, 5],
    [4, 1, 0, 1, 7],
]
for (r, row) in start.enumerated() {
    for (c, value) in row.enumerated() {
        field.add(value, row: r, column: c)
    }
}
print(field.sum(top: 1, left: 1, bottom: 2, right: 3))      // 6 + 3 + 2 + 2 + 0 + 1
field.add(10, row: 2, column: 2)
print(field.sum(top: 1, left: 1, bottom: 2, right: 3))
print(field.sum(top: 0, left: 0, bottom: 3, right: 4), field.sum(top: 3, left: 4, bottom: 3, right: 4))

// Compare with adding up the rectangle cell by cell, over 2,000 random operations on a 6 × 7 grid
var grid = Array(repeating: Array(repeating: 0, count: 7), count: 6)
var checked = Fenwick2D(rows: 6, columns: 7)
var state: UInt64 = 2
func next(_ limit: Int) -> Int {
    state = state &* 6364136223846793005 &+ 1442695040888963407
    return Int((state >> 33) % UInt64(limit))
}
var mismatches = 0
for _ in 0..<2_000 {
    if next(2) == 0 {
        let r = next(6), c = next(7), delta = next(21) - 10
        grid[r][c] += delta
        checked.add(delta, row: r, column: c)
    } else {
        let r1 = next(6), r2 = next(6), c1 = next(7), c2 = next(7)
        let top = min(r1, r2), bottom = max(r1, r2), left = min(c1, c2), right = max(c1, c2)
        var expected = 0
        for r in top...bottom {
            for c in left...right { expected += grid[r][c] }
        }
        if checked.sum(top: top, left: left, bottom: bottom, right: right) != expected { mismatches += 1 }
    }
}
print("mismatches:", mismatches)
