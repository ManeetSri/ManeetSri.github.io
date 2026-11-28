// Efficient sorts (M31 · Efficient sorting).
//
// Three tools from the module, as extensions on Array:
//
// - mergeSorted(by:) is a top-down merge sort that returns a new array. It's stable. Every merge
//   shares one scratch buffer, made once, instead of allocating new arrays at each level.
// - quickSort(by:) sorts in place. It picks a random pivot and partitions three ways (smaller,
//   equal, larger), so neither sorted input nor long runs of equal elements make it quadratic. It
//   recurses into the smaller side and loops on the larger, so the call stack stays O(log n) deep.
//   It isn't stable.
// - kthSmallest(_:by:) is quickselect: the element that would sit at index k after sorting.
//
// Both sorts hand short ranges to insertion sort, which is faster than splitting further when a
// range holds only a handful of elements. Every closure must be a strict weak ordering, exactly as
// for the standard library's sorted(by:): return true only when the first element must come before
// the second, and false for equal elements.

extension Array {
    /// Ranges this short are finished with insertion sort instead of being split further.
    private static var shortRangeLimit: Int { 16 }

    /// Returns the elements sorted by `areInIncreasingOrder`, using merge sort.
    ///
    /// The sort is **stable**: elements that `areInIncreasingOrder` treats as equal keep their
    /// original order. `areInIncreasingOrder` must be a strict weak ordering, as for `sorted(by:)`:
    /// use `<` or `>`, never `<=`.
    ///
    /// ```swift
    /// let words = ["pear", "fig", "plum", "kiwi"]
    /// words.mergeSorted { $0.count < $1.count }    // ["fig", "pear", "plum", "kiwi"]
    /// ```
    ///
    /// - Complexity: O(n log n) comparisons in every case, and O(n) for input that's already sorted.
    ///   O(n) extra memory for one scratch buffer, shared by every merge.
    public func mergeSorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        var elements = self
        guard elements.count > 1 else { return elements }
        var buffer = self                                // scratch space for every merge, made once
        Self.mergeSort(&elements, &buffer, 0, elements.count, areInIncreasingOrder)
        return elements
    }

    /// Sorts the elements in place by `areInIncreasingOrder`, using quick sort.
    ///
    /// Each pivot is chosen at random, and each range is split three ways (smaller than, equal to
    /// and larger than the pivot), so sorted input and many duplicates are both fast. The sort is
    /// **not stable**: equal elements can end up in any order. `areInIncreasingOrder` must be a
    /// strict weak ordering, as for `sort(by:)`.
    ///
    /// ```swift
    /// var scores = [72, 38, 91, 50, 38]
    /// scores.quickSort(by: >)                      // [91, 72, 50, 38, 38]
    /// ```
    ///
    /// - Complexity: O(n log n) expected for every input; the O(n²) worst case needs extraordinarily
    ///   unlucky pivots. O(log n) extra memory for the call stack.
    public mutating func quickSort(by areInIncreasingOrder: (Element, Element) -> Bool) {
        Self.quickSort(&self, 0, count, areInIncreasingOrder)
    }

    /// Returns the element that would be at index `k` if the array were sorted by
    /// `areInIncreasingOrder`, or nil if `k` isn't a valid index of the array.
    ///
    /// `k` is **0-based**, like an index: `kthSmallest(0, by: <)` is the smallest element,
    /// `kthSmallest(count - 1, by: <)` the largest, and `kthSmallest(count / 2, by: <)` the middle
    /// one. It runs quickselect, with random pivots and three-way partitioning, on a copy, so the
    /// array itself doesn't change.
    ///
    /// ```swift
    /// let times = [31, 12, 47, 12, 25]
    /// times.kthSmallest(1, by: <)                  // Optional(12)
    /// times.kthSmallest(0, by: >)                  // Optional(47), the largest
    /// ```
    ///
    /// - Complexity: O(n) expected for every input, O(n²) in the (vanishingly unlikely) worst case.
    ///   O(n) extra memory for the copy.
    public func kthSmallest(_ k: Int, by areInIncreasingOrder: (Element, Element) -> Bool) -> Element? {
        guard k >= 0 && k < count else { return nil }
        var elements = self
        var low = 0
        var high = elements.count
        while true {
            let (lessEnd, greaterStart) = Self.partition(&elements, low, high, areInIncreasingOrder)
            if k < lessEnd {
                high = lessEnd                           // the answer is smaller than the pivot
            } else if k >= greaterStart {
                low = greaterStart                       // the answer is larger than the pivot
            } else {
                return elements[k]                       // k landed among the copies of the pivot
            }
        }
    }

    // MARK: Merge sort

    /// Sorts `elements[low..<high]`, using `buffer` as scratch space.
    private static func mergeSort(
        _ elements: inout [Element], _ buffer: inout [Element], _ low: Int, _ high: Int,
        _ areInIncreasingOrder: (Element, Element) -> Bool
    ) {
        if high - low <= shortRangeLimit {
            insertionSortRange(&elements, low, high, areInIncreasingOrder)
            return
        }
        let mid = low + (high - low) / 2
        mergeSort(&elements, &buffer, low, mid, areInIncreasingOrder)
        mergeSort(&elements, &buffer, mid, high, areInIncreasingOrder)
        // The halves are already in order across the middle: there's nothing to merge
        if !areInIncreasingOrder(elements[mid], elements[mid - 1]) { return }
        merge(&elements, &buffer, low, mid, high, areInIncreasingOrder)
    }

    /// Merges the sorted runs `elements[low..<mid]` and `elements[mid..<high]`.
    private static func merge(
        _ elements: inout [Element], _ buffer: inout [Element], _ low: Int, _ mid: Int, _ high: Int,
        _ areInIncreasingOrder: (Element, Element) -> Bool
    ) {
        // Only the left run needs copying out: the write position never overtakes the right run
        for index in low..<mid {
            buffer[index] = elements[index]
        }
        var left = low
        var right = mid
        var write = low
        while left < mid && right < high {
            if areInIncreasingOrder(elements[right], buffer[left]) {
                elements[write] = elements[right]        // strictly smaller: the right one goes first
                right += 1
            } else {
                elements[write] = buffer[left]           // ties take the left one, which keeps it stable
                left += 1
            }
            write += 1
        }
        while left < mid {
            elements[write] = buffer[left]
            left += 1
            write += 1
        }
        // Anything left in the right run is already in its final place
    }

    // MARK: Quick sort and quickselect

    /// Sorts `elements[low..<high]` in place.
    private static func quickSort(
        _ elements: inout [Element], _ low: Int, _ high: Int,
        _ areInIncreasingOrder: (Element, Element) -> Bool
    ) {
        var low = low
        var high = high
        while high - low > shortRangeLimit {
            let (lessEnd, greaterStart) = partition(&elements, low, high, areInIncreasingOrder)
            // Recurse into the smaller side and loop on the larger, so the stack is O(log n) deep
            if lessEnd - low < high - greaterStart {
                quickSort(&elements, low, lessEnd, areInIncreasingOrder)
                low = greaterStart
            } else {
                quickSort(&elements, greaterStart, high, areInIncreasingOrder)
                high = lessEnd
            }
        }
        insertionSortRange(&elements, low, high, areInIncreasingOrder)
    }

    /// Partitions `elements[low..<high]` (not empty) three ways around a randomly chosen pivot, and
    /// returns `(lessEnd, greaterStart)`. Afterwards `low..<lessEnd` holds the elements that come
    /// before the pivot, `lessEnd..<greaterStart` the ones equal to it (never empty), and
    /// `greaterStart..<high` the ones that come after it.
    private static func partition(
        _ elements: inout [Element], _ low: Int, _ high: Int,
        _ areInIncreasingOrder: (Element, Element) -> Bool
    ) -> (Int, Int) {
        let pivot = elements[Int.random(in: low..<high)]
        var less = low                                   // low..<less: before the pivot
        var scan = low                                   // less..<scan: equal to it
        var greater = high                               // scan..<greater: not looked at yet
        while scan < greater {                           // greater..<high: after the pivot
            if areInIncreasingOrder(elements[scan], pivot) {
                elements.swapAt(less, scan)
                less += 1
                scan += 1
            } else if areInIncreasingOrder(pivot, elements[scan]) {
                greater -= 1
                elements.swapAt(scan, greater)           // the element swapped in is still unseen
            } else {
                scan += 1
            }
        }
        return (less, greater)
    }

    // MARK: Short ranges

    /// Stable insertion sort of `elements[low..<high]`, for short ranges.
    private static func insertionSortRange(
        _ elements: inout [Element], _ low: Int, _ high: Int,
        _ areInIncreasingOrder: (Element, Element) -> Bool
    ) {
        guard high - low > 1 else { return }
        for next in (low + 1)..<high {
            let element = elements[next]
            var slot = next
            while slot > low && areInIncreasingOrder(element, elements[slot - 1]) {
                elements[slot] = elements[slot - 1]
                slot -= 1
            }
            elements[slot] = element
        }
    }
}

extension Array where Element: Comparable {
    /// Returns the elements in increasing order, using a stable merge sort.
    ///
    /// ```swift
    /// [5, 2, 9, 1].mergeSorted()                   // [1, 2, 5, 9]
    /// ```
    ///
    /// - Complexity: O(n log n), and O(n) for input that's already sorted. O(n) extra memory.
    public func mergeSorted() -> [Element] {
        mergeSorted(by: <)
    }

    /// Sorts the elements into increasing order in place, using quick sort with random pivots and
    /// three-way partitioning.
    ///
    /// ```swift
    /// var numbers = [5, 2, 9, 1]
    /// numbers.quickSort()                          // [1, 2, 5, 9]
    /// ```
    ///
    /// - Complexity: O(n log n) expected. O(log n) extra memory.
    public mutating func quickSort() {
        quickSort(by: <)
    }

    /// Returns the element that would be at index `k` if the array were sorted into increasing
    /// order, or nil if `k` isn't a valid index. `k` is 0-based: `kthSmallest(0)` is the minimum.
    ///
    /// ```swift
    /// [31, 12, 47, 12, 25].kthSmallest(2)          // Optional(25)
    /// ```
    ///
    /// - Complexity: O(n) expected. O(n) extra memory.
    public func kthSmallest(_ k: Int) -> Element? {
        kthSmallest(k, by: <)
    }
}
