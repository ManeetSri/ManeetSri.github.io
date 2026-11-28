// The three elementary sorts (M30 · Elementary sorting).
//
// Each one sorts any mutable, random-access collection in place: an Array, an ArraySlice, a
// ContiguousArray, or a collection of your own such as DynamicArray. They move through the
// collection with `startIndex`, `endIndex`, `index(after:)` and `index(before:)`, never by adding to
// an index or assuming the first index is 0, so they sort slices correctly too:
//
//     var numbers = [9, 8, 7, 6, 5, 4]
//     numbers[1..<5].insertionSort()      // numbers is now [9, 5, 6, 7, 8, 4]
//
// All three take O(n²) time in the worst case. Insertion sort is the one worth using in real code:
// for short collections, and for collections that are already nearly sorted. For anything else, use
// the standard library's `sort()`.
//
// Every closure must be a strict weak ordering, exactly as for the standard library's sort(by:):
// return true only when the first element must come before the second, and false for equal
// elements. Pass `<` or `>`, never `<=` or `>=`.

extension MutableCollection where Self: RandomAccessCollection {
    /// Sorts the collection in place with bubble sort, so that `areInIncreasingOrder` holds for
    /// every pair of neighbours that aren't equal.
    ///
    /// Each pass swaps neighbours that are out of order, which carries the largest remaining element
    /// to the end of the unsorted part. The sort stops after the first pass that makes no swap.
    ///
    /// ```swift
    /// var scores = [5, 1, 4, 2, 8]
    /// scores.bubbleSort(by: >)        // [8, 5, 4, 2, 1]
    /// ```
    ///
    /// - Stable: equal elements keep their original relative order.
    /// - Complexity: O(n²) comparisons and swaps in the worst and average case, O(n) comparisons
    ///   when the collection is already sorted. O(1) extra space.
    public mutating func bubbleSort(by areInIncreasingOrder: (Element, Element) -> Bool) {
        var end = endIndex                       // everything from `end` on is sorted and final
        while end != startIndex {
            var swapped = false
            var current = startIndex
            var next = index(after: current)
            while next != end {
                // Swap only when the right one must come first: equal neighbours never cross
                if areInIncreasingOrder(self[next], self[current]) {
                    swapAt(current, next)
                    swapped = true
                }
                current = next
                formIndex(after: &next)
            }
            if !swapped { return }               // a pass with no swaps: already sorted
            formIndex(before: &end)
        }
    }

    /// Sorts the collection in place with selection sort, so that `areInIncreasingOrder` holds for
    /// every pair of neighbours that aren't equal.
    ///
    /// Each pass finds the smallest element of the unsorted part and swaps it to the front of that
    /// part, where it stays.
    ///
    /// ```swift
    /// var words = ["pear", "fig", "apple"]
    /// words.selectionSort(by: <)      // ["apple", "fig", "pear"]
    /// ```
    ///
    /// - Not stable: a swap can carry an element past others equal to it.
    /// - Complexity: always n(n − 1)/2 comparisons, even for sorted input, but at most n − 1 swaps,
    ///   which makes it a fit when writing elements is expensive. O(1) extra space.
    public mutating func selectionSort(by areInIncreasingOrder: (Element, Element) -> Bool) {
        var front = startIndex                   // everything before `front` is sorted and final
        while front != endIndex {
            var smallest = front
            var candidate = index(after: front)
            while candidate != endIndex {
                if areInIncreasingOrder(self[candidate], self[smallest]) {
                    smallest = candidate
                }
                formIndex(after: &candidate)
            }
            if smallest != front {
                swapAt(front, smallest)
            }
            formIndex(after: &front)
        }
    }

    /// Sorts the collection in place with insertion sort, so that `areInIncreasingOrder` holds for
    /// every pair of neighbours that aren't equal.
    ///
    /// The front of the collection is kept sorted. Each new element is taken out, the larger
    /// elements before it shift one place right, and it drops into the gap they leave.
    ///
    /// ```swift
    /// var ages = [31, 12, 47, 12, 5]
    /// ages.insertionSort(by: <)       // [5, 12, 12, 31, 47]
    /// ```
    ///
    /// - Stable: equal elements keep their original relative order.
    /// - Complexity: O(n + d) time, where d is the number of pairs that are out of order. That's
    ///   O(n) for sorted input, O(n · k) when every element is at most k places from where it
    ///   belongs, and O(n²) in the worst case. O(1) extra space.
    public mutating func insertionSort(by areInIncreasingOrder: (Element, Element) -> Bool) {
        guard !isEmpty else { return }
        var next = index(after: startIndex)      // everything before `next` is sorted
        while next != endIndex {
            let key = self[next]
            var gap = next
            while gap != startIndex {
                let before = index(before: gap)
                // Stop at the first element that isn't bigger than the key: that keeps it stable
                guard areInIncreasingOrder(key, self[before]) else { break }
                self[gap] = self[before]          // shift it one place right
                gap = before
            }
            if gap != next {
                self[gap] = key
            }
            formIndex(after: &next)
        }
    }
}

extension MutableCollection where Self: RandomAccessCollection, Element: Comparable {
    /// Sorts the collection into increasing order in place with bubble sort.
    ///
    /// - Stable. O(n²) worst and average case, O(n) when already sorted. O(1) extra space.
    public mutating func bubbleSort() {
        bubbleSort(by: <)
    }

    /// Sorts the collection into increasing order in place with selection sort.
    ///
    /// - Not stable. Always O(n²) comparisons, at most n − 1 swaps. O(1) extra space.
    public mutating func selectionSort() {
        selectionSort(by: <)
    }

    /// Sorts the collection into increasing order in place with insertion sort.
    ///
    /// - Stable. O(n + d) for d out-of-order pairs: O(n) when sorted, O(n²) at worst. O(1) extra
    ///   space.
    public mutating func insertionSort() {
        insertionSort(by: <)
    }
}
