// Generated from src/dsa/content/lessons/backtracking/bk-word-search.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func traceCalls(_ board: [String], _ word: String, pruned: Bool) -> (found: Bool, calls: Int) {
    var grid = board.map { Array($0) }
    var letters = Array(word)
    let rows = grid.count
    let columns = grid[0].count
    if pruned {
        var inGrid: [Character: Int] = [:]
        for row in grid {
            for letter in row { inGrid[letter, default: 0] += 1 }
        }
        var inWord: [Character: Int] = [:]
        for letter in letters { inWord[letter, default: 0] += 1 }
        for (letter, count) in inWord where inGrid[letter, default: 0] < count {
            return (false, 0)                            // not enough of some letter: no search at all
        }
        if inGrid[letters[0], default: 0] > inGrid[letters[letters.count - 1], default: 0] {
            letters.reverse()                            // start from the rarer end
        }
    }
    var calls = 0
    func trace(_ row: Int, _ column: Int, _ index: Int) -> Bool {
        calls += 1
        guard row >= 0, row < rows, column >= 0, column < columns,
              grid[row][column] == letters[index] else { return false }
        if index == letters.count - 1 { return true }
        let saved = grid[row][column]
        grid[row][column] = "#"
        defer { grid[row][column] = saved }
        return trace(row - 1, column, index + 1) || trace(row + 1, column, index + 1)
            || trace(row, column - 1, index + 1) || trace(row, column + 1, index + 1)
    }
    for row in 0..<rows {
        for column in 0..<columns where trace(row, column, 0) {
            return (true, calls)
        }
    }
    return (false, calls)
}

let allA = Array(repeating: "AAAAA", count: 5)
let fenced = ["BCAAA", "CAAAA", "AAAAA", "AAAAA", "AAAAA"]
let word = String(repeating: "A", count: 11) + "B"
print("no B, plain: ", traceCalls(allA, word, pruned: false))
print("no B, pruned:", traceCalls(allA, word, pruned: true))
print("fenced B, plain: ", traceCalls(fenced, word, pruned: false))
print("fenced B, pruned:", traceCalls(fenced, word, pruned: true))
