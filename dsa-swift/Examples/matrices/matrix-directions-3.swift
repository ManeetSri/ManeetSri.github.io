// Generated from src/dsa/content/lessons/matrices/matrix-directions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let board: [[Character]] = [
    ["C", "A", "T"],
    ["A", "A", "A"],
    ["T", "A", "C"],
]
let directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
let word: [Character] = ["C", "A", "T"]

func matches(from row: Int, _ column: Int, heading: (Int, Int)) -> Bool {
    for (step, letter) in word.enumerated() {
        let r = row + heading.0 * step
        let c = column + heading.1 * step
        guard r >= 0 && r < board.count && c >= 0 && c < board[r].count && board[r][c] == letter else {
            return false
        }
    }
    return true
}

var found: [String] = []
for row in board.indices {
    for column in board[row].indices {
        for heading in directions where matches(from: row, column, heading: heading) {
            found.append("(\(row), \(column)) heading \(heading)")
        }
    }
}
print(found.count)
for line in found {
    print(line)
}
