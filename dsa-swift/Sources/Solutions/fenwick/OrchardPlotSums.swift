// Reference solution: Orchard plot sums. A 2D Fenwick tree: slot (i, j) holds the sum of the rows i is
// responsible for crossed with the columns j is responsible for, so the 1D loops nest. Setting a plot
// adds the difference from its old count, which a copy of the grid remembers. A rectangle is four
// prefix rectangles by inclusion–exclusion. The build passes totals up along each row, then up along
// each column: O(rows × columns). Each set or total is O(log rows × log columns).

public enum OrchardPlotSums {
    public struct Orchard {
        private var tree: [[Int]]                  // 1-indexed in both directions
        private var plots: [[Int]]
        private let rows: Int
        private let columns: Int

        public init(_ grid: [[Int]]) {
            plots = grid
            rows = grid.count
            columns = grid.first?.count ?? 0
            tree = Array(repeating: Array(repeating: 0, count: columns + 1), count: rows + 1)
            for r in 0..<rows {
                for c in 0..<columns {
                    tree[r + 1][c + 1] = grid[r][c]
                }
            }
            // The O(n) 1D build, first along every row, then along every column
            for i in 1..<(rows + 1) {
                for j in 1..<(columns + 1) {
                    let parent = j + (j & -j)
                    if parent <= columns { tree[i][parent] += tree[i][j] }
                }
            }
            for i in 1..<(rows + 1) {
                let parent = i + (i & -i)
                if parent <= rows {
                    for j in 1..<(columns + 1) {
                        tree[parent][j] += tree[i][j]
                    }
                }
            }
        }

        public mutating func set(row: Int, column: Int, to value: Int) {
            let delta = value - plots[row][column]
            plots[row][column] = value
            var i = row + 1
            while i <= rows {
                var j = column + 1
                while j <= columns {
                    tree[i][j] += delta
                    j += j & -j
                }
                i += i & -i
            }
        }

        /// The sum of rows 0..<rowCount and columns 0..<columnCount.
        private func prefix(_ rowCount: Int, _ columnCount: Int) -> Int {
            var total = 0
            var i = rowCount
            while i > 0 {
                var j = columnCount
                while j > 0 {
                    total += tree[i][j]
                    j -= j & -j
                }
                i -= i & -i
            }
            return total
        }

        public func total(top: Int, left: Int, bottom: Int, right: Int) -> Int {
            prefix(bottom + 1, right + 1) - prefix(top, right + 1) - prefix(bottom + 1, left) + prefix(top, left)
        }
    }
}
