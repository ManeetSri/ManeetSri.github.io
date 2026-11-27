// Reference solution: Smaller values to the right. Merge sort an array of indices by their values.
// When the merge takes an index from the left half, every index already taken from the right half has
// a smaller value and a later position, so that element's tally grows by the number taken from the
// right so far. Ties take the left element first, so equal values are never counted. One merge sort:
// O(n log n) time, O(n) extra space.

public enum SmallerToTheRight {
    public static func counts(_ numbers: [Int]) -> [Int] {
        let n = numbers.count
        var tally = Array(repeating: 0, count: n)
        var order = Array(0..<n)                // positions, merge sorted by their values
        var buffer = order

        func sort(_ low: Int, _ high: Int) {
            guard high - low > 1 else { return }
            let mid = low + (high - low) / 2
            sort(low, mid)
            sort(mid, high)
            for index in low..<high {
                buffer[index] = order[index]
            }
            var left = low
            var right = mid
            for write in low..<high {
                if right == high || (left < mid && numbers[buffer[left]] <= numbers[buffer[right]]) {
                    tally[buffer[left]] += right - mid      // smaller values from the right, already placed
                    order[write] = buffer[left]
                    left += 1
                } else {
                    order[write] = buffer[right]
                    right += 1
                }
            }
        }

        sort(0, n)
        return tally
    }
}
