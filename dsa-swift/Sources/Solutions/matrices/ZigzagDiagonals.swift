// Reference solution: Zigzag diagonals. The cells of anti-diagonal d are those with row + column == d.
// For each d, the rows run from max(0, d - (columns - 1)) to min(d, rows - 1); walk them bottom to
// top when d is even (upwards) and top to bottom when d is odd. O(rows × columns) time.

public enum ZigzagDiagonals {
    public static func order(_ grid: [[Int]]) -> [Int] {
        let rows = grid.count
        guard rows > 0, let columns = grid.first?.count, columns > 0 else { return [] }

        var result: [Int] = []
        result.reserveCapacity(rows * columns)
        for d in 0...(rows + columns - 2) {
            let firstRow = max(0, d - (columns - 1))
            let lastRow = min(d, rows - 1)
            if d % 2 == 0 {
                for row in stride(from: lastRow, through: firstRow, by: -1) {
                    result.append(grid[row][d - row])
                }
            } else {
                for row in firstRow...lastRow {
                    result.append(grid[row][d - row])
                }
            }
        }
        return result
    }
}
