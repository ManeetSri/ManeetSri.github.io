// Problem: Windows, chunks and adjacent pairs (M69 · swift-algorithms)

public enum SliceWindowHelpers {
    /// Every run of `count` consecutive elements of `base`, in order, as slices of `base` (so they keep
    /// its indexes). Empty when `base` has fewer than `count` elements. `count` is at least 1.
    public static func windows<C: Collection>(of base: C, count: Int) -> [C.SubSequence] {
        // Write your solution here, then run:
        // swift test --filter SliceWindowHelpersTests
        return []
    }

    /// Consecutive, non-overlapping slices of `count` elements, in order; the last one holds whatever is
    /// left and may be shorter. Empty when `base` is empty. `count` is at least 1.
    public static func chunks<C: Collection>(of base: C, count: Int) -> [C.SubSequence] {
        return []
    }

    /// Each element paired with the element after it, in order. Empty when `base` has fewer than two
    /// elements.
    public static func adjacentPairs<C: Collection>(of base: C) -> [(C.Element, C.Element)] {
        return []
    }
}
