// Reference solution: Search a sorted grid. Start in the top-right corner. A value bigger than the
// target rules out its whole column (everything below is bigger still), so step left; a smaller
// value rules out its whole row, so step down. Each step discards a row or a column:
// O(rows + columns) time, O(1) space.

public enum StaircaseSearch {
    public static func find(_ target: Int, in grid: [[Int]]) -> (row: Int, column: Int)? {
        guard let width = grid.first?.count, width > 0 else { return nil }
        var row = 0
        var column = width - 1
        while row < grid.count && column >= 0 {
            let value = grid[row][column]
            if value == target {
                return (row, column)
            } else if value > target {
                column -= 1
            } else {
                row += 1
            }
        }
        return nil
    }
}
