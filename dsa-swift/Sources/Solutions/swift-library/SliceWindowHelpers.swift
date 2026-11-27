// Reference solution: Windows, chunks and adjacent pairs. Each function moves indexes with
// index(_:offsetBy:limitedBy:) and formIndex(after:), never assuming Int indexes from 0, so it works on
// strings and slices too, and returns slices of the base instead of copies.
// windows: O(n) to build all n − k + 1 slices (O(k) to find the first window's end).
// chunks: O(n). adjacentPairs: O(n). Each result array is the only extra space.

public enum SliceWindowHelpers {
    public static func windows<C: Collection>(of base: C, count: Int) -> [C.SubSequence] {
        guard count > 0,
              var end = base.index(base.startIndex, offsetBy: count, limitedBy: base.endIndex)
        else { return [] }
        var start = base.startIndex
        var result = [base[start..<end]]
        // Slide both ends one step at a time until the window's end reaches the end of the base
        while end != base.endIndex {
            base.formIndex(after: &start)
            base.formIndex(after: &end)
            result.append(base[start..<end])
        }
        return result
    }

    public static func chunks<C: Collection>(of base: C, count: Int) -> [C.SubSequence] {
        guard count > 0 else { return [] }
        var result: [C.SubSequence] = []
        var start = base.startIndex
        while start != base.endIndex {
            // limitedBy stops at endIndex instead of running past it, which makes the last chunk short
            let end = base.index(start, offsetBy: count, limitedBy: base.endIndex) ?? base.endIndex
            result.append(base[start..<end])
            start = end
        }
        return result
    }

    public static func adjacentPairs<C: Collection>(of base: C) -> [(C.Element, C.Element)] {
        Array(zip(base, base.dropFirst()))
    }
}
