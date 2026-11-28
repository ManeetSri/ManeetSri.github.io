// Problem: Counting trail routes (M58 · DP on DAGs; Counting with modulo)

public enum TrailRouteCount {
    /// Junctions 0..<n are joined by one-way trails [from, to], and no route ever comes back to a junction
    /// it has left (the trails form a DAG). Returns the number of different routes from `start` to
    /// `finish`, modulo 1,000,000,007. Two trails between the same junctions count as different routes.
    /// A route from a junction to itself, using no trails, counts as one.
    public static func countRoutes(n: Int, trails: [[Int]], start: Int, finish: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter TrailRouteCountTests
        return 0
    }
}
