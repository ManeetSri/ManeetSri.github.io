// Reference solution: Cells that drain to both seas. Reverse the flow: instead of following water
// downhill from every cell, start from each sea's edge cells and climb to neighbours that are at
// least as high, since water could flow from there back down to here. One traversal per sea marks
// every cell that drains into it, and the answer is the cells marked by both, in row-major order.
// Each traversal is an iterative DFS: O(rows × columns) time and space.

public enum TwoSeaDrainage {
    private static let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    public static func cells(_ heights: [[Int]]) -> [[Int]] {
        guard let columns = heights.first?.count, columns > 0 else { return [] }
        let rows = heights.count

        func drainsInto(from edge: [(Int, Int)]) -> [[Bool]] {
            var reached = Array(repeating: Array(repeating: false, count: columns), count: rows)
            var stack: [(Int, Int)] = []
            for (row, column) in edge where !reached[row][column] {
                reached[row][column] = true
                stack.append((row, column))
            }
            while let cell = stack.popLast() {
                for (dr, dc) in directions {
                    let r = cell.0 + dr
                    let c = cell.1 + dc
                    guard r >= 0, r < rows, c >= 0, c < columns, !reached[r][c] else { continue }
                    guard heights[r][c] >= heights[cell.0][cell.1] else { continue }   // uphill or level
                    reached[r][c] = true
                    stack.append((r, c))
                }
            }
            return reached
        }

        let northWest = drainsInto(from: (0..<rows).map { ($0, 0) } + (0..<columns).map { (0, $0) })
        let southEast = drainsInto(from: (0..<rows).map { ($0, columns - 1) } + (0..<columns).map { (rows - 1, $0) })
        var result: [[Int]] = []
        for row in 0..<rows {
            for column in 0..<columns where northWest[row][column] && southEast[row][column] {
                result.append([row, column])
            }
        }
        return result
    }
}
