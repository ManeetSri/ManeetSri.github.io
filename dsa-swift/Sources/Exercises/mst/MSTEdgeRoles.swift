// Problem: Critical and optional links (M46 · Connect all points and other MST problems)

import DSAKit

public enum MSTEdgeRoles {
    /// Nodes are 0..<n, and edges[i] = [a, b, weight] is link i of a connected graph. A link is
    /// critical if every minimum spanning tree uses it, and pseudo-critical if some but not all do.
    /// Returns the indices of each kind, in increasing order.
    public static func classify(_ n: Int, _ edges: [[Int]]) -> (critical: [Int], pseudoCritical: [Int]) {
        // Write your solution here, then run:
        // swift test --filter MSTEdgeRolesTests
        return ([], [])
    }
}
