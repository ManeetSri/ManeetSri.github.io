// Generated from src/dsa/content/lessons/backtracking/bk-sudoku.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let cells = "..53.....8......2..7..1.5..4....53...1..7...6..32...8..6.5....9..4....3......97.."
let digits = cells.map { $0.wholeNumberValue ?? 0 }
var rowDigits = Array(repeating: 0, count: 9)        // bit d set: digit d is in that row
var columnDigits = Array(repeating: 0, count: 9)
var boxDigits = Array(repeating: 0, count: 9)
for index in 0..<81 where digits[index] != 0 {
    let row = index / 9
    let column = index % 9
    let bit = 1 << digits[index]
    rowDigits[row] |= bit
    columnDigits[column] |= bit
    boxDigits[row / 3 * 3 + column / 3] |= bit
}

func candidates(_ row: Int, _ column: Int) -> Int {
    ~(rowDigits[row] | columnDigits[column] | boxDigits[row / 3 * 3 + column / 3]) & 0b11_1111_1110
}

func list(_ mask: Int) -> [Int] {
    var found: [Int] = []
    var rest = mask
    while rest != 0 {
        found.append(rest.trailingZeroBitCount)      // the lowest set bit's position is the digit
        rest &= rest - 1                             // clear that bit
    }
    return found
}

for (row, column) in [(0, 0), (0, 1), (4, 2), (8, 8)] {
    let mask = candidates(row, column)
    print("(\(row), \(column)):", list(mask), "count", mask.nonzeroBitCount)
}
