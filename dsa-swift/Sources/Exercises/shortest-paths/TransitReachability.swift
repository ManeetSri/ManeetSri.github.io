// Problem: Which stations can reach which (M44 · Floyd–Warshall)

public enum TransitReachability {
    /// Stations are numbered 0..<stationCount, and each connection [from, to] runs one way. For each
    /// query [a, b], answers whether b can be reached from a by following connections (every station
    /// can reach itself).
    public static func canReach(stationCount: Int, connections: [[Int]], queries: [[Int]]) -> [Bool] {
        // Write your solution here, then run:
        // swift test --filter TransitReachabilityTests
        return []
    }
}
