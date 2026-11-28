// Problem: Audit a distance table (M44 · Weighted graphs and the shortest-path problem)

public enum DistanceTableAudit {
    /// Places are numbered 0..<places, and each road [a, b, minutes] can be driven both ways. Returns
    /// true if `claimed` is exactly right: `claimed[v]` is the fewest minutes from `start` to v, or nil
    /// for every place that can't be reached. Aim for O(places + roads).
    public static func isExact(places: Int, roads: [[Int]], start: Int, claimed: [Int?]) -> Bool {
        // Write your solution here, then run:
        // swift test --filter DistanceTableAuditTests
        return false
    }
}
