// Generated from src/dsa/content/lessons/backtracking/bk-n-queens.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func solveQueens(_ n: Int) -> [[Int]] {
    var queenColumn: [Int] = []                                  // queenColumn[row]: that row's queen
    var columnTaken = Array(repeating: false, count: n)
    var downTaken = Array(repeating: false, count: 2 * n - 1)    // "\" diagonals: row - column + n - 1
    var upTaken = Array(repeating: false, count: 2 * n - 1)      // "/" diagonals: row + column
    var solutions: [[Int]] = []

    func place(_ row: Int) {
        if row == n {
            solutions.append(queenColumn)
            return
        }
        for column in 0..<n {
            let down = row - column + n - 1
            let up = row + column
            if columnTaken[column] || downTaken[down] || upTaken[up] { continue }   // attacked
            queenColumn.append(column)                           // choose
            columnTaken[column] = true
            downTaken[down] = true
            upTaken[up] = true
            place(row + 1)                                       // explore
            queenColumn.removeLast()                             // unchoose all four
            columnTaken[column] = false
            downTaken[down] = false
            upTaken[up] = false
        }
    }

    place(0)
    return solutions
}

func draw(_ columns: [Int]) {
    for column in columns {
        print(columns.indices.map { $0 == column ? "Q" : "." }.joined(separator: " "))
    }
}

let four = solveQueens(4)
print(four)
draw(four[0])
let eight = solveQueens(8)
print(eight.count, "solutions for 8 queens; the first is", eight[0])
