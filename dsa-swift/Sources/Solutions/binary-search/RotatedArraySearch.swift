// Reference solution: Search a rotated sorted array. One binary search. At any middle index, at least
// one of the two halves, low...mid or mid...high, is sorted, and comparing the ends tells you which.
// If the target lies within the sorted half's range, search there; otherwise it can only be in the
// other half. O(log n) time, O(1) space. (Needs distinct values: with duplicates, numbers[low] ==
// numbers[mid] wouldn't say which half is sorted.)

public enum RotatedArraySearch {
    public static func index(of target: Int, in numbers: [Int]) -> Int? {
        var low = 0
        var high = numbers.count - 1
        while low <= high {
            let mid = low + (high - low) / 2
            if numbers[mid] == target {
                return mid
            }
            if numbers[low] <= numbers[mid] {
                // low...mid is sorted
                if numbers[low] <= target && target < numbers[mid] {
                    high = mid - 1
                } else {
                    low = mid + 1
                }
            } else {
                // mid...high is sorted
                if numbers[mid] < target && target <= numbers[high] {
                    low = mid + 1
                } else {
                    high = mid - 1
                }
            }
        }
        return nil
    }
}
