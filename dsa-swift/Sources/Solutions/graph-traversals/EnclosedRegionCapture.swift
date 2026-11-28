// Reference solution: Capture enclosed regions. Think in reverse: an "O" survives exactly when it's
// connected to an "O" on the border. Push every border "O" onto a stack, marking it safe ("S"), and
// spread through neighbouring "O"s with an iterative DFS. Then one sweep turns every remaining "O"
// into "X" and every "S" back into "O". O(rows × columns) time and space.

public enum EnclosedRegionCapture {
    private static let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    public static func capture(_ board: [[Character]]) -> [[Character]] {
        var board = board
        guard let columns = board.first?.count, columns > 0 else { return board }
        let rows = board.count

        var stack: [(Int, Int)] = []
        for row in 0..<rows {
            for column in 0..<columns where row == 0 || row == rows - 1 || column == 0 || column == columns - 1 {
                if board[row][column] == "O" {
                    board[row][column] = "S"
                    stack.append((row, column))
                }
            }
        }
        while let cell = stack.popLast() {
            for (dr, dc) in directions {
                let r = cell.0 + dr
                let c = cell.1 + dc
                guard r >= 0, r < rows, c >= 0, c < columns, board[r][c] == "O" else { continue }
                board[r][c] = "S"                        // safe: connected to the border
                stack.append((r, c))
            }
        }

        for row in 0..<rows {
            for column in 0..<columns {
                board[row][column] = board[row][column] == "S" ? "O" : "X"
            }
        }
        return board
    }
}
