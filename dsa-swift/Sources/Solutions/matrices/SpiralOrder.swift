// Reference solution: Spiral order. Four boundaries close in on the unvisited rectangle: walk the top
// row, the right column, the bottom row backwards and the left column upwards, moving each boundary
// inwards after its side is done. The two guards stop a single remaining row or column being walked
// twice. O(rows × columns) time, O(1) extra space besides the result.

public enum SpiralOrder {
    public static func values(_ grid: [[Int]]) -> [Int] {
        guard let width = grid.first?.count, width > 0 else { return [] }
        var top = 0
        var bottom = grid.count - 1
        var left = 0
        var right = width - 1
        var result: [Int] = []
        result.reserveCapacity(grid.count * width)

        while top <= bottom && left <= right {
            for column in left...right {
                result.append(grid[top][column])
            }
            top += 1

            if top <= bottom {
                for row in top...bottom {
                    result.append(grid[row][right])
                }
            }
            right -= 1

            if top <= bottom && left <= right {
                for column in stride(from: right, through: left, by: -1) {
                    result.append(grid[bottom][column])
                }
                bottom -= 1
            }

            if left <= right && top <= bottom {
                for row in stride(from: bottom, through: top, by: -1) {
                    result.append(grid[row][left])
                }
                left += 1
            }
        }
        return result
    }
}
