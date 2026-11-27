// Problem: Generic picks (M10 · Generic functions and constraints)

public enum GenericPicks {
    // Write your solution here, then run:
    // swift test --filter GenericPicksTests

    /// Returns the largest item, or nil if `items` is empty.
    public static func largest<T: Comparable>(_ items: [T]) -> T? {
        return nil
    }

    /// Returns the item that appears most often, or nil if `items` is empty. If several items tie,
    /// returns the one whose first appearance comes earliest.
    public static func mostFrequent<T: Hashable>(_ items: [T]) -> T? {
        return nil
    }
}
