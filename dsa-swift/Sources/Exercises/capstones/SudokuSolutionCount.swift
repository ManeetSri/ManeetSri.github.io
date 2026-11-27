// Problem: Sudoku solution count (M74 · A Sudoku solver and generator)

public enum SudokuSolutionCount {
    /// How many ways the grid can be completed, counting no further than `limit`. The grid is 9
    /// strings of 9 characters, "1" to "9" or "."; givens that break the rules mean 0.
    public static func solutions(_ rows: [String], limit: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter SudokuSolutionCountTests
        return -1
    }

    /// True when the puzzle has exactly one solution and removing any one of its clues allows more.
    public static func isMinimal(_ rows: [String]) -> Bool {
        return false
    }
}
