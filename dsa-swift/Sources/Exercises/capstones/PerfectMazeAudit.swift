// Problem: Perfect maze audit (M74 · A maze generator and solver)

public enum PerfectMazeAudit {
    /// True when every cell can reach every other in exactly one way: the passages form a spanning tree.
    /// `openRight[r][c]` joins (r, c) to (r, c + 1); `openDown[r][c]` joins (r, c) to (r + 1, c).
    public static func isPerfect(openRight: [[Bool]], openDown: [[Bool]]) -> Bool {
        // Write your solution here, then run:
        // swift test --filter PerfectMazeAuditTests
        return false
    }

    /// The most steps between any two cells of a perfect maze, or nil if the maze isn't perfect.
    public static func longestRoute(openRight: [[Bool]], openDown: [[Bool]]) -> Int? {
        return -1
    }
}
