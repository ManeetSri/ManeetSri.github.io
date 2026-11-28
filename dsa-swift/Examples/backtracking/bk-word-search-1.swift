// Generated from src/dsa/content/lessons/backtracking/bk-word-search.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func exists(_ board: [[Character]], _ word: String) -> Bool {
    var grid = board                                     // a copy we're free to mark
    let letters = Array(word)
    let rows = grid.count
    let columns = grid[0].count

    func trace(_ row: Int, _ column: Int, _ index: Int) -> Bool {
        guard row >= 0, row < rows, column >= 0, column < columns,
              grid[row][column] == letters[index] else { return false }
        if index == letters.count - 1 { return true }    // matched the last letter
        let saved = grid[row][column]
        grid[row][column] = "#"                          // choose: this cell is in use
        defer { grid[row][column] = saved }              // unchoose, however we leave
        return trace(row - 1, column, index + 1) || trace(row + 1, column, index + 1)
            || trace(row, column - 1, index + 1) || trace(row, column + 1, index + 1)
    }

    for row in 0..<rows {
        for column in 0..<columns where trace(row, column, 0) {
            return true
        }
    }
    return false
}

let board: [[Character]] = [
    ["S", "E", "A", "L"],
    ["T", "A", "R", "E"],
    ["O", "N", "E", "S"],
]
for word in ["STONE", "SEAL", "ONES", "RARE", "EARS"] {
    print(word, exists(board, word))
}
