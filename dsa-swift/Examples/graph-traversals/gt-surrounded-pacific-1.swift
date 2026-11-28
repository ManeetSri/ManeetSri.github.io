// Generated from src/dsa/content/lessons/graph-traversals/gt-surrounded-pacific.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

func capture(_ board: [[Character]]) -> [[Character]] {
    var board = board
    let rows = board.count
    let columns = board[0].count
    // 1. Every "O" on the border is safe: mark it "S" and start the search from it
    var stack: [(Int, Int)] = []
    for row in 0..<rows {
        for column in 0..<columns where row == 0 || row == rows - 1 || column == 0 || column == columns - 1 {
            if board[row][column] == "O" {
                board[row][column] = "S"
                stack.append((row, column))
            }
        }
    }
    // 2. Anything connected to a safe "O" is safe too
    while let cell = stack.popLast() {
        for (dr, dc) in directions {
            let r = cell.0 + dr
            let c = cell.1 + dc
            guard r >= 0, r < rows, c >= 0, c < columns, board[r][c] == "O" else { continue }
            board[r][c] = "S"
            stack.append((r, c))
        }
    }
    // 3. Unmarked "O"s are enclosed: capture them, and restore the safe ones
    for row in 0..<rows {
        for column in 0..<columns {
            board[row][column] = board[row][column] == "S" ? "O" : "X"
        }
    }
    return board
}

let board = [
    "XXXXXX",
    "XOOXOX",
    "XXOXOX",
    "XOXXOO",
    "XOOXXX",
    "XXXXOX",
].map { Array($0) }

for (before, after) in zip(board, capture(board)) {
    print(String(before), " → ", String(after))
}
