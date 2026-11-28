// Reference solution: Gentlest hiking route. The effort of a route is its largest step, and adding a
// step can never lower that, so Dijkstra still works with `max` in place of `+`: pop the cell with the
// least effort so far, and relax each neighbour with max(effort, |height difference|). Stop when the
// bottom-right cell is popped. O(R · C · log(R · C)) time, O(R · C) space.

import DSAKit

public enum GentlestHikingRoute {
    public static func minimumEffort(_ heights: [[Int]]) -> Int {
        let rows = heights.count, cols = heights[0].count
        var effort = Array(repeating: Array(repeating: Int.max, count: cols), count: rows)
        effort[0][0] = 0
        var heap = Heap<(effort: Int, row: Int, col: Int)>(areInIncreasingOrder: { $0.effort < $1.effort })
        heap.insert((0, 0, 0))
        let steps = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        while let (current, row, col) = heap.pop() {
            if current > effort[row][col] { continue }  // stale entry
            if row == rows - 1 && col == cols - 1 { return current }
            for (dr, dc) in steps {
                let r = row + dr, c = col + dc
                guard r >= 0, r < rows, c >= 0, c < cols else { continue }
                let candidate = max(current, abs(heights[r][c] - heights[row][col]))
                if candidate < effort[r][c] {
                    effort[r][c] = candidate
                    heap.insert((candidate, r, c))
                }
            }
        }
        return effort[rows - 1][cols - 1]
    }
}
