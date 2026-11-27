// Reference solution: Next permutation. Find the pivot, the rightmost element smaller than the one
// after it; everything after it is in non-increasing order, its largest arrangement. Swap the pivot
// with the rightmost element bigger than it, then reverse the suffix into its smallest arrangement.
// With no pivot, reversing the whole array wraps round to the smallest. O(n) time, O(1) space.

public enum NextPermutation {
    public static func advance(_ numbers: inout [Int]) -> Bool {
        let count = numbers.count

        // Reverses numbers[low...] in place
        func reverseSuffix(from low: Int) {
            var left = low
            var right = count - 1
            while left < right {
                numbers.swapAt(left, right)
                left += 1
                right -= 1
            }
        }

        // 1. The pivot: the rightmost index with numbers[pivot] < numbers[pivot + 1]
        var pivot = count - 2
        while pivot >= 0 && numbers[pivot] >= numbers[pivot + 1] {
            pivot -= 1
        }
        guard pivot >= 0 else {
            reverseSuffix(from: 0)        // the last arrangement: wrap to the first
            return false
        }

        // 2. The rightmost element bigger than the pivot (the suffix is non-increasing)
        var successor = count - 1
        while numbers[successor] <= numbers[pivot] {
            successor -= 1
        }
        numbers.swapAt(pivot, successor)

        // 3. The suffix is still non-increasing: reverse it to make it as small as possible
        reverseSuffix(from: pivot + 1)
        return true
    }
}
