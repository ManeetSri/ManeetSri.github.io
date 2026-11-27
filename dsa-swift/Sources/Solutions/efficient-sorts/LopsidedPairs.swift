// Reference solution: Lopsided pairs. Merge sort, with a counting pass before each merge. Both halves
// are sorted, so as `i` walks up the left half, the right-half values `v` with numbers[i] > 2v form a
// prefix of the right half that only grows: one pointer `j` finds its end, and the pass is O(n).
// Then an ordinary merge. O(n log n) time, O(n) extra space. Values fit in 32 bits, so 2 * v can't
// overflow a 64-bit Int.

public enum LopsidedPairs {
    public static func count(in numbers: [Int]) -> Int {
        var items = numbers
        var buffer = numbers
        return sortAndCount(&items, &buffer, 0, items.count)
    }

    /// Sorts items[low..<high] and returns the number of lopsided pairs inside it.
    private static func sortAndCount(_ items: inout [Int], _ buffer: inout [Int], _ low: Int, _ high: Int) -> Int {
        guard high - low > 1 else { return 0 }
        let mid = low + (high - low) / 2
        var pairs = sortAndCount(&items, &buffer, low, mid) + sortAndCount(&items, &buffer, mid, high)

        // Count the pairs with i in the left half and j in the right half
        var j = mid
        for i in low..<mid {
            while j < high && items[i] > 2 * items[j] {
                j += 1
            }
            pairs += j - mid
        }

        // Merge the halves
        for index in low..<high {
            buffer[index] = items[index]
        }
        var left = low
        var right = mid
        for write in low..<high {
            if right == high || (left < mid && buffer[left] <= buffer[right]) {
                items[write] = buffer[left]
                left += 1
            } else {
                items[write] = buffer[right]
                right += 1
            }
        }
        return pairs
    }
}
