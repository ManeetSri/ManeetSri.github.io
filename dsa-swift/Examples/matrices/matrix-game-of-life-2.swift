// Generated from src/dsa/content/lessons/matrices/matrix-game-of-life.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let moves = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]

func step(_ board: [[Int]]) -> [[Int]] {
    let rows = board.count
    let columns = board[0].count
    var next = board
    for r in 0..<rows {
        for c in 0..<columns {
            var alive = 0
            for (dr, dc) in moves {
                let nr = r + dr
                let nc = c + dc
                if nr >= 0 && nr < rows && nc >= 0 && nc < columns {
                    alive += board[nr][nc]        // always the old board
                }
            }
            next[r][c] = alive == 3 || (board[r][c] == 1 && alive == 2) ? 1 : 0
        }
    }
    return next
}

func show(_ board: [[Int]]) {
    for row in board {
        print(String(row.map { $0 == 1 ? "#" : "." }))
    }
}

var glider = Array(repeating: Array(repeating: 0, count: 6), count: 6)
for (r, c) in [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)] {
    glider[r][c] = 1
}
show(glider)
for _ in 1...4 {
    glider = step(glider)
}
print("after 4 generations:")
show(glider)
