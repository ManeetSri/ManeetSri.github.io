// Reference solution: Search a fully sorted grid. Every row continues where the previous one ended, so
// reading the grid row by row gives one sorted list of rows × columns values. Binary search that
// virtual list: position i is row i / columns, column i % columns. O(log(rows × columns)) time,
// O(1) space.

public enum SortedMatrixSearch {
    public static func position(of target: Int, in grid: [[Int]]) -> (row: Int, column: Int)? {
        guard let firstRow = grid.first, !firstRow.isEmpty else { return nil }
        let columns = firstRow.count
        var low = 0
        var high = grid.count * columns - 1
        while low <= high {
            let mid = low + (high - low) / 2
            let value = grid[mid / columns][mid % columns]
            if value == target {
                return (mid / columns, mid % columns)
            } else if value < target {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        return nil
    }
}
