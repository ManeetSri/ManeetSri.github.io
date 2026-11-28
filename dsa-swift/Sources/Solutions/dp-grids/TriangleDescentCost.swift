// Reference solution: Cheapest triangle descent. Fill from the base upwards: best[i] is the cheapest
// way from position i of the current row down to the base. Every position has exactly two children,
// so there are no edge cases, and the apex ends up holding the answer. Going left to right, best[i + 1]
// is still the row below when best[i] is overwritten, so one array is enough. O(n²) time for n rows
// (every number once), O(n) space.

public enum TriangleDescentCost {
    public static func cheapest(_ triangle: [[Int]]) -> Int {
        guard var best = triangle.last else { return 0 }
        for r in stride(from: triangle.count - 2, through: 0, by: -1) {
            for i in 0...r {
                best[i] = triangle[r][i] + min(best[i], best[i + 1])
            }
        }
        return best[0]
    }
}
