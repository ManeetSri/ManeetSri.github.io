// Reference solution: Sort five with seven comparisons. Up to 4 values, binary insertion meets the bound
// (0, 1, 3 and 5 comparisons). For 5, Ford and Johnson's merge insertion: compare two pairs, then their
// winners, giving a ≤ b ≤ d and c ≤ d in 3 comparisons; binary-insert e into [a, b, d] (2), then c
// into the part of the chain before d (at most 3 values, 2 comparisons). 7 = ⌈log₂ 120⌉ in total.

public enum FewestComparisonSort {
    public static func sorted(_ values: [Int], by isLess: (Int, Int) -> Bool) -> [Int] {
        guard values.count == 5 else {
            var result: [Int] = []                               // binary insertion: 0, 1, 3 or 5 calls
            for value in values {
                insert(value, into: &result, before: result.count, by: isLess)
            }
            return result
        }
        var (a, b, c, d, e) = (values[0], values[1], values[2], values[3], values[4])
        if isLess(b, a) { swap(&a, &b) }                         // a ≤ b
        if isLess(d, c) { swap(&c, &d) }                         // c ≤ d
        if isLess(d, b) {                                        // make b ≤ d by swapping the pairs
            swap(&a, &c)
            swap(&b, &d)
        }
        var chain = [a, b, d]                                    // a ≤ b ≤ d, and c ≤ d
        let placeOfE = insert(e, into: &chain, before: 3, by: isLess)            // 2 calls
        let placeOfD = placeOfE <= 2 ? 3 : 2                     // e went before d, or after it
        insert(c, into: &chain, before: placeOfD, by: isLess)                    // at most 2 calls
        return chain
    }

    /// Inserts value into the sorted prefix sorted[0..<end] by binary search, returning its position.
    @discardableResult
    private static func insert(_ value: Int, into sorted: inout [Int], before end: Int,
                               by isLess: (Int, Int) -> Bool) -> Int {
        var low = 0
        var high = end
        while low < high {
            let mid = (low + high) / 2
            if isLess(value, sorted[mid]) { high = mid } else { low = mid + 1 }
        }
        sorted.insert(value, at: low)
        return low
    }
}
