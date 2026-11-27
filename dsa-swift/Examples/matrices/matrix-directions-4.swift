// Generated from src/dsa/content/lessons/matrices/matrix-directions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let knightMoves = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)]

func knightMoveCount(_ row: Int, _ column: Int) -> Int {
    var count = 0
    for (dr, dc) in knightMoves {
        let r = row + dr
        let c = column + dc
        if r >= 0 && r < 8 && c >= 0 && c < 8 {
            count += 1
        }
    }
    return count
}

print(knightMoveCount(0, 0), knightMoveCount(0, 1), knightMoveCount(3, 3))
