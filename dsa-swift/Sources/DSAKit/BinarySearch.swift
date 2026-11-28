// Binary search for any random-access collection (M28 · Binary search).
//
// Everything here is one idea: in a collection whose elements answer a yes/no question as
// "no, no, …, no, yes, yes, …, yes", find the first "yes". The search keeps a half-open range of
// candidates, `[low, low + count)`, and halves it with every question it asks. The first "yes" is
// always inside the range, or at its end when every element says "no".
//
// Indexes are moved with `index(_:offsetBy:)`, never by adding to them, so the code works for any
// index type and for slices whose indexes don't start at 0.
//
// The generic method is called `partitionPoint(where:)` rather than `partitioningIndex(where:)`, the
// name swift-algorithms uses, so the two can never clash in a file that imports both.

extension RandomAccessCollection {
    /// Returns the index of the first element that satisfies `belongsInSecondPartition`, or
    /// `endIndex` if no element does.
    ///
    /// The collection must already be partitioned by the predicate: every element for which it's
    /// false comes before every element for which it's true.
    ///
    /// ```swift
    /// let scores = [12, 31, 48, 50, 77, 91]
    /// scores.partitionPoint { $0 >= 50 }     // 3
    /// scores.partitionPoint { $0 > 100 }     // 6, endIndex: no score is over 100
    /// ```
    ///
    /// If the collection isn't partitioned, the result is some index, but not a meaningful one.
    ///
    /// - Complexity: O(log n) calls to the predicate, where n is the length of the collection.
    public func partitionPoint(
        where belongsInSecondPartition: (Element) throws -> Bool
    ) rethrows -> Index {
        var low = startIndex
        var remaining = count                    // the candidates are [low, low + remaining)
        while remaining > 0 {
            let half = remaining / 2
            let middle = index(low, offsetBy: half)
            if try belongsInSecondPartition(self[middle]) {
                remaining = half                 // middle could be the first "yes": keep it
            } else {
                low = index(after: middle)       // middle and everything before it say "no"
                remaining -= half + 1
            }
        }
        return low
    }
}

extension RandomAccessCollection where Element: Comparable {
    /// Returns the index of the first element that is greater than or equal to `value`, or
    /// `endIndex` if every element is smaller. The collection must be sorted in increasing order.
    ///
    /// This is where `value` would be inserted to keep the collection sorted, before any equal
    /// elements.
    ///
    /// ```swift
    /// let sorted = [1, 3, 3, 3, 5, 8]
    /// sorted.lowerBound(of: 3)     // 1
    /// sorted.lowerBound(of: 4)     // 4
    /// sorted.lowerBound(of: 9)     // 6, endIndex
    /// ```
    ///
    /// - Complexity: O(log n) comparisons.
    public func lowerBound(of value: Element) -> Index {
        partitionPoint { $0 >= value }
    }

    /// Returns the index of the first element that is greater than `value`, or `endIndex` if no
    /// element is. The collection must be sorted in increasing order.
    ///
    /// This is where `value` would be inserted to keep the collection sorted, after any equal
    /// elements. The number of elements equal to `value` is
    /// `distance(from: lowerBound(of: value), to: upperBound(of: value))`.
    ///
    /// ```swift
    /// let sorted = [1, 3, 3, 3, 5, 8]
    /// sorted.upperBound(of: 3)     // 4
    /// sorted.upperBound(of: 0)     // 0
    /// ```
    ///
    /// - Complexity: O(log n) comparisons.
    public func upperBound(of value: Element) -> Index {
        partitionPoint { $0 > value }
    }

    /// Returns the index of the first element equal to `value`, or nil if there is none. The
    /// collection must be sorted in increasing order.
    ///
    /// When `value` appears more than once, the result is always its first occurrence.
    ///
    /// ```swift
    /// let sorted = [2, 5, 5, 9]
    /// sorted.binarySearch(for: 5)     // Optional(1)
    /// sorted.binarySearch(for: 4)     // nil
    /// ```
    ///
    /// - Complexity: O(log n) comparisons.
    public func binarySearch(for value: Element) -> Index? {
        let candidate = lowerBound(of: value)
        return candidate != endIndex && self[candidate] == value ? candidate : nil
    }
}
