// Reference solution: Target-sum submatrices. Fix a top row, then grow the bottom row one at a time,
// keeping the column sums between them. Each submatrix between those rows is a subarray of the column
// sums, so the 1D prefix sum + dictionary count finishes the job. O(rows² × columns) time,
// O(columns) space.

public enum TargetSumSubmatrices {
    public static func count(in grid: [[Int]], summingTo target: Int) -> Int {
        let rows = grid.count
        let columns = grid.first?.count ?? 0
        var total = 0
        for top in 0..<rows {
            var columnSums = Array(repeating: 0, count: columns)
            for bottom in top..<rows {
                for c in 0..<columns {
                    columnSums[c] += grid[bottom][c]
                }
                // Count subarrays of columnSums that add up to target
                var seen: [Int: Int] = [0: 1]
                var running = 0
                for value in columnSums {
                    running += value
                    total += seen[running - target, default: 0]
                    seen[running, default: 0] += 1
                }
            }
        }
        return total
    }
}
