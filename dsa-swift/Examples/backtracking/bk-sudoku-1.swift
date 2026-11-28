// Generated from src/dsa/content/lessons/backtracking/bk-sudoku.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func parse(_ cells: String) -> [[Int]] {
    let digits = cells.map { $0.wholeNumberValue ?? 0 }      // "." becomes 0: empty
    return (0..<9).map { Array(digits[($0 * 9)..<($0 * 9 + 9)]) }
}

var grid = parse("..53.....8......2..7..1.5..4....53...1..7...6..32...8..6.5....9..4....3......97..")
var placements = 0

func canPlace(_ digit: Int, _ row: Int, _ column: Int) -> Bool {
    for i in 0..<9 where grid[row][i] == digit || grid[i][column] == digit {
        return false                                         // already in the row or column
    }
    let top = row / 3 * 3
    let left = column / 3 * 3
    for r in top..<(top + 3) {
        for c in left..<(left + 3) where grid[r][c] == digit {
            return false                                     // already in the box
        }
    }
    return true
}

func solve(_ position: Int) -> Bool {
    if position == 81 { return true }                        // past the last cell: solved
    let row = position / 9
    let column = position % 9
    if grid[row][column] != 0 { return solve(position + 1) } // a given digit: move on
    for digit in 1...9 where canPlace(digit, row, column) {
        grid[row][column] = digit                            // choose
        placements += 1
        if solve(position + 1) { return true }               // explore; stop at the first solution
    }
    grid[row][column] = 0                                    // unchoose: nothing fitted
    return false
}

print(solve(0), placements, "placements")
for row in grid {
    print(row.map(String.init).joined())
}
