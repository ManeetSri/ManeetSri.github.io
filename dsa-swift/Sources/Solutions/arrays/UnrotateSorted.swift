// Reference solution: Undo a rotation. A rotated sorted array has at most one "drop", a place where
// numbers[i] > numbers[i + 1]. Everything after the drop belongs at the front, so rotate left by
// i + 1 with three reversals. O(n) time, O(1) extra space.

public enum UnrotateSorted {
    public static func unrotate(_ numbers: inout [Int]) {
        let count = numbers.count
        guard count > 1 else { return }

        // Find the drop. With no drop the array is already sorted.
        var drop: Int? = nil
        for index in 0..<(count - 1) where numbers[index] > numbers[index + 1] {
            drop = index
            break
        }
        guard let last = drop else { return }

        // Reverses numbers[low...high] in place
        func reverse(_ low: Int, _ high: Int) {
            var left = low
            var right = high
            while left < right {
                numbers.swapAt(left, right)
                left += 1
                right -= 1
            }
        }

        // Rotating left by `last + 1`: reverse both parts, then the whole array
        reverse(0, last)
        reverse(last + 1, count - 1)
        reverse(0, count - 1)
    }
}
