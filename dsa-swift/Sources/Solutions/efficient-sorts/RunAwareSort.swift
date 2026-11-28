// Reference solution: A sort that spots runs. Natural merge sort. First, one pass splits the input
// into its natural runs: stretches already in order. A strictly descending stretch is reversed into
// an ascending run (it has no equal elements, so reversing can't break stability). Each adjacent pair
// is compared exactly once, so this pass costs n - 1 comparisons, and sorted input is done. Then
// merge neighbouring runs in pairs, pass after pass, like bottom-up merge sort: r runs take
// ⌈log₂ r⌉ passes of at most n comparisons each. Ties take the left run's element: stable.
// O(n log n) time in the worst case, O(n) for sorted or reversed input, O(n) extra space.

public enum RunAwareSort {
    public static func sorted<Element>(
        _ items: [Element], by areInIncreasingOrder: (Element, Element) -> Bool
    ) -> [Element] {
        var elements = items
        let n = elements.count
        guard n > 1 else { return elements }

        // 1. Find the natural runs. Run r is elements[bounds[r]..<bounds[r + 1]].
        var bounds = [0]
        var start = 0
        while start < n {
            var end = start + 1
            if end < n && areInIncreasingOrder(elements[end], elements[start]) {
                end += 1                                 // strictly descending: extend, then reverse
                while end < n && areInIncreasingOrder(elements[end], elements[end - 1]) {
                    end += 1
                }
                elements[start..<end].reverse()
            } else if end < n {
                end += 1                                 // ascending (equal neighbours allowed)
                while end < n && !areInIncreasingOrder(elements[end], elements[end - 1]) {
                    end += 1
                }
            }
            bounds.append(end)
            start = end
        }

        // 2. Merge neighbouring runs in pairs until one run is left
        var buffer = elements
        while bounds.count > 2 {
            var merged = [0]
            var pair = 0
            while pair + 2 < bounds.count {
                merge(&elements, &buffer, bounds[pair], bounds[pair + 1], bounds[pair + 2], areInIncreasingOrder)
                merged.append(bounds[pair + 2])
                pair += 2
            }
            if pair + 1 < bounds.count {
                merged.append(bounds[pair + 1])          // an odd run out waits for the next pass
            }
            bounds = merged
        }
        return elements
    }

    /// Merges the sorted runs elements[low..<mid] and elements[mid..<high].
    private static func merge<Element>(
        _ elements: inout [Element], _ buffer: inout [Element], _ low: Int, _ mid: Int, _ high: Int,
        _ areInIncreasingOrder: (Element, Element) -> Bool
    ) {
        for index in low..<mid {
            buffer[index] = elements[index]              // copy out the left run only
        }
        var left = low
        var right = mid
        var write = low
        while left < mid && right < high {
            if areInIncreasingOrder(elements[right], buffer[left]) {
                elements[write] = elements[right]
                right += 1
            } else {
                elements[write] = buffer[left]           // ties take the left run's element
                left += 1
            }
            write += 1
        }
        while left < mid {
            elements[write] = buffer[left]
            left += 1
            write += 1
        }
    }
}
