// Reference solution: Look it up in a sorted array. Classic binary search over the closed range
// [low, high]: if the target is anywhere, it's in that range. Compare the middle value with the target
// and throw away the half that can't hold it. O(log n) time, O(1) space.

public enum SortedLookup {
    public static func index(of target: Int, in numbers: [Int]) -> Int? {
        var low = 0
        var high = numbers.count - 1
        while low <= high {
            let mid = low + (high - low) / 2
            if numbers[mid] == target {
                return mid
            } else if numbers[mid] < target {
                low = mid + 1                    // mid and everything left of it are too small
            } else {
                high = mid - 1                   // mid and everything right of it are too big
            }
        }
        return nil
    }
}
