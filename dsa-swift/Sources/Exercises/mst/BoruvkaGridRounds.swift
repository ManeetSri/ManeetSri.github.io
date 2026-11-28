// Problem: Build the grid in rounds (M46 · Borůvka's algorithm)

import DSAKit

public enum BoruvkaGridRounds {
    /// Towns are numbered 0..<towns, and each possible power line [a, b, cost] joins two of them.
    /// Every town starts as its own grid. Each round, every grid with a line to another grid picks its
    /// cheapest such line (by cost, then by position in `lines`), and all picked lines are built at
    /// once, merging grids. Rounds stop when no line joins two different grids. Returns the total cost
    /// of the lines built and the number of separate grids after each round.
    public static func plan(towns: Int, lines: [[Int]]) -> (cost: Int, gridsAfterRound: [Int]) {
        // Write your solution here, then run:
        // swift test --filter BoruvkaGridRoundsTests
        // DSAKit's UnionFind is imported, if you want it.
        return (0, [])
    }
}
