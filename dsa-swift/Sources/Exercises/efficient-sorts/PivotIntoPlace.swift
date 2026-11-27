// Problem: Put the pivot in its place (M31 · Quick sort: Lomuto and Hoare)

public enum PivotIntoPlace {
    /// Partitions `numbers[low...high]` around its last element, the pivot `numbers[high]`, and
    /// returns the index where the pivot ends up. Afterwards every element in `low..<p` is less
    /// than the pivot, `numbers[p]` is the pivot, and every element in `(p + 1)...high` is greater
    /// than or equal to it. Elements outside `low...high` don't move.
    public static func partition(_ numbers: inout [Int], low: Int, high: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter PivotIntoPlaceTests
        return 0
    }
}
