// Reference solution: Count the inversions. Merge sort, counting as it merges. When the merge takes
// a value from the right half, that value is smaller than every value still waiting in the left
// half, and each of those is an inversion: add `mid - left` in one step. Ties take the left value
// and count nothing, because equal values aren't inversions. O(n log n) time, O(n) extra space.

public enum InversionCount {
    public static func count(in numbers: [Int]) -> Int {
        var items = numbers
        var buffer = numbers
        return sortAndCount(&items, &buffer, 0, items.count)
    }

    /// Sorts items[low..<high] and returns the number of inversions it held.
    private static func sortAndCount(_ items: inout [Int], _ buffer: inout [Int], _ low: Int, _ high: Int) -> Int {
        guard high - low > 1 else { return 0 }
        let mid = low + (high - low) / 2
        var inversions = sortAndCount(&items, &buffer, low, mid) + sortAndCount(&items, &buffer, mid, high)
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
                inversions += mid - left                 // smaller than everything left in the left half
            }
        }
        return inversions
    }
}
