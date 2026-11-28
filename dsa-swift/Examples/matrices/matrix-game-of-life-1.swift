// Generated from src/dsa/content/lessons/matrices/matrix-game-of-life.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var board = [
    [0, 0, 0],
    [1, 1, 1],
    [0, 0, 0],
]
let moves = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
for r in 0..<3 {
    for c in 0..<3 {
        var alive = 0
        for (dr, dc) in moves {
            let nr = r + dr
            let nc = c + dc
            if nr >= 0 && nr < 3 && nc >= 0 && nc < 3 {
                alive += board[nr][nc]
            }
        }
        board[r][c] = alive == 3 || (board[r][c] == 1 && alive == 2) ? 1 : 0
    }
}
for row in board {
    print(row)
}
