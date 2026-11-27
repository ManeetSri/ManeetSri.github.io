// Reference solution: Zero the rows and columns. The first row and first column serve as marker
// arrays: grid[r][0] == 0 means "zero row r" and grid[0][c] == 0 means "zero column c". Two flags
// remember whether the first row and column themselves need zeroing, because their markers would
// otherwise be confused with original zeroes. O(rows × columns) time, O(1) extra space.

public enum ZeroRowsAndColumns {
    public static func spreadZeroes(_ grid: inout [[Int]]) {
        let rows = grid.count
        guard rows > 0, let columns = grid.first?.count, columns > 0 else { return }

        let zeroFirstRow = grid[0].contains(0)
        let zeroFirstColumn = grid.contains { $0[0] == 0 }

        // 1. Record each zero in the inner grid on the first row and column
        for row in 1..<rows {
            for column in 1..<columns where grid[row][column] == 0 {
                grid[row][0] = 0
                grid[0][column] = 0
            }
        }

        // 2. Zero the inner cells whose row or column is marked
        for row in 1..<rows {
            for column in 1..<columns where grid[row][0] == 0 || grid[0][column] == 0 {
                grid[row][column] = 0
            }
        }

        // 3. Finally the first row and column, which held the markers
        if zeroFirstRow {
            for column in 0..<columns {
                grid[0][column] = 0
            }
        }
        if zeroFirstColumn {
            for row in 0..<rows {
                grid[row][0] = 0
            }
        }
    }
}
