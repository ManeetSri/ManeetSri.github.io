// Problem: Robot route across the warehouse (M44 · A* search)

import DSAKit

public enum WarehouseRobotRoute {
    /// `floor[r][c]` is the cost of driving into that cell (1 to 9), or 0 for a shelf the robot can't
    /// enter. Moving up, down, left or right from `start` to `goal` (each [row, col]), returns the lowest
    /// total cost, or -1 if the goal can't be reached. The start cell itself costs nothing.
    public static func cheapestRoute(_ floor: [[Int]], start: [Int], goal: [Int]) -> Int {
        // Write your solution here, then run:
        // swift test --filter WarehouseRobotRouteTests
        // DSAKit's Heap is imported, if you want it.
        return 0
    }
}
