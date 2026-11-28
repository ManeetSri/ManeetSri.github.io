// Reference solution: Transpose a grid.
// Build a cols × rows grid of zeros, then copy each value across: result[c][r] = grid[r][c].
// O(rows × cols) time and space.

public enum GridTranspose {
    public static func transpose(_ grid: [[Int]]) -> [[Int]] {
        guard let cols = grid.first?.count, cols > 0 else { return [] }
        let rows = grid.count
        var result = Array(repeating: Array(repeating: 0, count: rows), count: cols)
        for r in 0..<rows {
            for c in 0..<cols {
                result[c][r] = grid[r][c]
            }
        }
        return result
    }
}
