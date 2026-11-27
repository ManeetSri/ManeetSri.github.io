// Reference solution: Disorder after each arrival. When value x arrives as the item at index i, the
// new inversions are the earlier items strictly greater than x: i minus the earlier items at most x.
// Compress the values to ranks 1...m (only their order matters), keep a Fenwick tree of how many items
// of each rank have arrived, and keep a running total. O(n log n) time, O(n) space.

public enum ArrivalDisorder {
    public static func inversionCounts(_ values: [Int]) -> [Int] {
        // Coordinate compression: each value's rank among the distinct values, counting from 1
        let distinct = Array(Set(values)).sorted()
        var rankOf: [Int: Int] = [:]
        for (offset, value) in distinct.enumerated() {
            rankOf[value] = offset + 1
        }

        var tree = Array(repeating: 0, count: distinct.count + 1)   // counts by rank, 1-indexed
        var total = 0
        var result: [Int] = []
        result.reserveCapacity(values.count)
        for (index, value) in values.enumerated() {
            let rank = rankOf[value]!
            var atMost = 0                                         // earlier items with rank <= this one
            var i = rank
            while i > 0 {
                atMost += tree[i]
                i -= i & -i
            }
            total += index - atMost                                // the earlier items that are greater
            result.append(total)
            i = rank
            while i < tree.count {
                tree[i] += 1
                i += i & -i
            }
        }
        return result
    }
}
