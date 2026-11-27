// Generated from src/dsa/content/lessons/backtracking/bk-sudoku.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Sudoku {
    var grid: [[Int]]
    var rowHas = Array(repeating: Array(repeating: false, count: 10), count: 9)
    var columnHas = Array(repeating: Array(repeating: false, count: 10), count: 9)
    var boxHas = Array(repeating: Array(repeating: false, count: 10), count: 9)
    var placements = 0

    init(_ cells: String) {
        let digits = cells.map { $0.wholeNumberValue ?? 0 }
        grid = (0..<9).map { Array(digits[($0 * 9)..<($0 * 9 + 9)]) }
        for row in 0..<9 {
            for column in 0..<9 where grid[row][column] != 0 {
                mark(grid[row][column], row, column, true)
            }
        }
    }

    func fits(_ digit: Int, _ row: Int, _ column: Int) -> Bool {
        !rowHas[row][digit] && !columnHas[column][digit] && !boxHas[row / 3 * 3 + column / 3][digit]
    }

    mutating func mark(_ digit: Int, _ row: Int, _ column: Int, _ on: Bool) {
        rowHas[row][digit] = on
        columnHas[column][digit] = on
        boxHas[row / 3 * 3 + column / 3][digit] = on
        grid[row][column] = on ? digit : 0
    }

    /// The empty cell to fill next, or nil if the grid is full
    func nextCell(mostConstrained: Bool) -> (row: Int, column: Int)? {
        var best: (row: Int, column: Int)?
        var fewest = 10
        for row in 0..<9 {
            for column in 0..<9 where grid[row][column] == 0 {
                if !mostConstrained { return (row, column) }    // reading order: the first empty cell
                var candidates = 0
                for digit in 1...9 where fits(digit, row, column) {
                    candidates += 1
                }
                if candidates < fewest {
                    best = (row, column)
                    fewest = candidates
                    if fewest <= 1 { return best }              // dead end or forced: look no further
                }
            }
        }
        return best
    }

    mutating func solve(mostConstrained: Bool) -> Bool {
        guard let (row, column) = nextCell(mostConstrained: mostConstrained) else { return true }
        for digit in 1...9 where fits(digit, row, column) {
            mark(digit, row, column, true)                      // choose
            placements += 1
            if solve(mostConstrained: mostConstrained) { return true }   // explore
            mark(digit, row, column, false)                     // unchoose
        }
        return false                                            // no digit fits here: back up
    }
}

let puzzle = "..9748...7.........2.1.9.....7...24..64.1.59..98...3.....8.3.2.........6...2759.."
for mostConstrained in [false, true] {
    var sudoku = Sudoku(puzzle)
    let solved = sudoku.solve(mostConstrained: mostConstrained)
    print(mostConstrained ? "most constrained cell:" : "first empty cell:     ", solved, sudoku.placements, "placements")
    print("  first row:", sudoku.grid[0].map(String.init).joined())
}
