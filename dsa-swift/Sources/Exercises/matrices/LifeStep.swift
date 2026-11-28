// Problem: Game of Life, one step (M19 · Game of Life)

public enum LifeStep {
    /// `board` is a rectangle of cells, 1 for alive and 0 for dead. Advances it one generation of
    /// Conway's Game of Life, in place: a live cell with 2 or 3 live neighbours survives, a dead cell
    /// with exactly 3 comes alive, and every other cell ends up dead. Cells beyond the edge are dead.
    public static func advance(_ board: inout [[Int]]) {
        // Write your solution here, then run:
        // swift test --filter LifeStepTests
    }
}
