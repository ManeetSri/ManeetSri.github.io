// Generated from src/dsa/content/lessons/backtracking/bk-n-queens.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countQueens(_ n: Int) -> (solutions: Int, nodes: Int) {
    var columnTaken = Array(repeating: false, count: n)
    var downTaken = Array(repeating: false, count: 2 * n - 1)
    var upTaken = Array(repeating: false, count: 2 * n - 1)
    var nodes = 0

    func place(_ row: Int) -> Int {
        nodes += 1
        if row == n { return 1 }                                 // one complete board
        var total = 0
        for column in 0..<n where !columnTaken[column] && !downTaken[row - column + n - 1] && !upTaken[row + column] {
            columnTaken[column] = true
            downTaken[row - column + n - 1] = true
            upTaken[row + column] = true
            total += place(row + 1)
            columnTaken[column] = false
            downTaken[row - column + n - 1] = false
            upTaken[row + column] = false
        }
        return total
    }

    let solutions = place(0)
    return (solutions, nodes)
}

for n in 4...10 {
    let (solutions, nodes) = countQueens(n)
    print("n = \(n): \(solutions) solutions, \(nodes) nodes")
}
