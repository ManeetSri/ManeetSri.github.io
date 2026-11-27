// Reference solution: Game of Life, one step. Each cell keeps two bits: bit 0 is its state now, bit 1
// its state in the next generation. The first pass counts neighbours using only bit 0 (`& 1`), so
// cells already updated still report their old state, and sets bit 1. The second pass shifts every
// cell right by one. O(rows × columns) time, O(1) extra space.

public enum LifeStep {
    private static let moves = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]

    public static func advance(_ board: inout [[Int]]) {
        let rows = board.count
        guard rows > 0, let columns = board.first?.count, columns > 0 else { return }

        for row in 0..<rows {
            for column in 0..<columns {
                var alive = 0
                for (dr, dc) in moves {
                    let r = row + dr
                    let c = column + dc
                    if r >= 0 && r < rows && c >= 0 && c < columns {
                        alive += board[r][c] & 1
                    }
                }
                let isAlive = board[row][column] & 1 == 1
                if alive == 3 || (isAlive && alive == 2) {
                    board[row][column] |= 2       // alive in the next generation
                }
            }
        }

        for row in 0..<rows {
            for column in 0..<columns {
                board[row][column] >>= 1
            }
        }
    }
}
