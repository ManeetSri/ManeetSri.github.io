// Problem: Copies while an array grows (M14 · Amortised analysis)

public enum GrowthCopies {
    /// Elements copied over `n` appends to an array that starts with capacity 1 and doubles
    /// its capacity whenever an append finds it full. Don't simulate every append.
    public static func copiesWhenDoubling(appends n: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter GrowthCopiesTests
        return 0
    }

    /// Elements copied over `n` appends to an array that starts with capacity 1 and adds
    /// `step` to its capacity whenever an append finds it full. Answer in O(1).
    public static func copiesWhenGrowing(by step: Int, appends n: Int) -> Int {
        return 0
    }
}
