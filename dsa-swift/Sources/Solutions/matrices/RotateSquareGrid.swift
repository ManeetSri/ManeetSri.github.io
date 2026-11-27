// Reference solution: Rotate a square grid. A clockwise quarter turn is a transpose (swap each cell
// above the main diagonal with its mirror below it) followed by reversing every row.
// O(n²) time, O(1) extra space.

public enum RotateSquareGrid {
    public static func rotateClockwise(_ grid: inout [[Int]]) {
        let size = grid.count
        for row in 0..<size {
            for column in (row + 1)..<size {
                let saved = grid[row][column]
                grid[row][column] = grid[column][row]
                grid[column][row] = saved
            }
        }
        for row in 0..<size {
            grid[row].reverse()
        }
    }
}
