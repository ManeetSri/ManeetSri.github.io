// Reference solution: Grid region sums. A summed-area table with an extra row and column of zeros:
// prefix[r][c] is the sum of rows 0..<r and columns 0..<c. Each rectangle is four lookups by
// inclusion-exclusion. O(rows × columns) to build, O(1) per query.

public enum GridRegionSums {
    public struct Table {
        private let prefix: [[Int]]

        public init(_ grid: [[Int]]) {
            let rows = grid.count
            let columns = grid.first?.count ?? 0
            var prefix = Array(repeating: Array(repeating: 0, count: columns + 1), count: rows + 1)
            for r in 0..<rows {
                for c in 0..<columns {
                    prefix[r + 1][c + 1] = grid[r][c] + prefix[r][c + 1] + prefix[r + 1][c] - prefix[r][c]
                }
            }
            self.prefix = prefix
        }

        public func sum(top: Int, left: Int, bottom: Int, right: Int) -> Int {
            prefix[bottom + 1][right + 1] - prefix[top][right + 1] - prefix[bottom + 1][left] + prefix[top][left]
        }
    }
}
