// Reference solution: Largest rectangle in a histogram. A stack keeps bar indexes with increasing
// heights. When a lower bar arrives, each taller bar popped has found its right boundary (the lower
// bar) and its left boundary (the bar now under it on the stack), so its widest rectangle is known.
// A sentinel bar of height 0 at the end empties the stack. O(n) time, O(n) space.
//
// The grid version treats each row as the floor of a histogram: a column's height is the number of
// 1s running up from that row. O(rows × columns) time, O(columns) space.

public enum HistogramRectangle {
    public static func largestArea(_ heights: [Int]) -> Int {
        var rising: [Int] = []
        var best = 0
        for index in 0...heights.count {
            let height = index < heights.count ? heights[index] : 0
            while let top = rising.last, heights[top] >= height {
                rising.removeLast()
                let left = rising.last ?? -1
                best = max(best, heights[top] * (index - left - 1))
            }
            rising.append(index)
        }
        return best
    }

    public static func largestRectangle(in grid: [[Int]]) -> Int {
        guard let width = grid.first?.count else {
            return 0
        }
        var heights = Array(repeating: 0, count: width)
        var best = 0
        for row in grid {
            for column in 0..<width {
                heights[column] = row[column] == 1 ? heights[column] + 1 : 0
            }
            best = max(best, largestArea(heights))
        }
        return best
    }
}
