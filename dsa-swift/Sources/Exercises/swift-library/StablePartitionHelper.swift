// Problem: Stable partition (M69 · Standard library algorithms)

public enum StablePartitionHelper {
    /// Reorders `items` so that every element for which `belongsInSecondPartition` is false comes
    /// before every element for which it's true, keeping the original relative order within both
    /// groups. Calls the predicate exactly once per element. Returns the index of the first element
    /// of the second group (`items.count` if there is none).
    public static func stablePartition<T>(_ items: inout [T], by belongsInSecondPartition: (T) -> Bool) -> Int {
        // Write your solution here, then run:
        // swift test --filter StablePartitionHelperTests
        return 0
    }
}
