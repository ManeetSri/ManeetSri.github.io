// Problem: Groups after each road closure (M47 · Which graph algorithm when)

import DSAKit

public enum StormRoadClosures {
    /// Towns are numbered 0..<towns, and each road [a, b] is two-way. During a storm the roads in
    /// `closures` close one at a time: `closures[k]` is the index in `roads` of the k-th road to close,
    /// and no road closes twice. Returns, for each k, the number of separate groups of towns (towns
    /// that can still reach each other) just after the k-th closure.
    public static func groupsAfterEachClosure(towns: Int, roads: [[Int]], closures: [Int]) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter StormRoadClosuresTests
        // DSAKit's UnionFind is imported, if you want it.
        return []
    }
}
