// Problem: Flatten a nested list (M17 · Base case and recursive case)

public enum NestedListFlatten {
    /// Either a single number, or a list whose items are themselves numbers or lists.
    public indirect enum Item: Equatable {
        case number(Int)
        case list([Item])
    }

    // Write your solution here, then run:
    // swift test --filter NestedListFlattenTests

    /// Every number inside `item`, in the order they appear from left to right.
    public static func flatten(_ item: Item) -> [Int] {
        return []
    }

    /// How deeply `item` is nested: a number has depth 0, and a list has depth one more than its
    /// deepest item (an empty list has depth 1).
    public static func depth(_ item: Item) -> Int {
        return 0
    }
}
