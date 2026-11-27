// Reference solution: The single value among pairs. Before the single value, every pair starts at an
// even index; after it, every pair starts at an odd index. So look at the pair that should start at
// an even index mid: if numbers[mid] == numbers[mid + 1], the pattern still holds and the single
// value is further right; otherwise it's at mid or to its left. low and high stay even throughout.
// O(log n) time, O(1) space.

public enum SingleInPairs {
    public static func single(in numbers: [Int]) -> Int {
        var low = 0
        var high = numbers.count - 1             // the single value's index is in [low, high], and even
        while low < high {
            var mid = low + (high - low) / 2
            if mid % 2 == 1 {
                mid -= 1                         // the pair that should start here starts at an even index
            }
            if numbers[mid] == numbers[mid + 1] {
                low = mid + 2                    // an intact pair: the single value is after it
            } else {
                high = mid                       // the pattern broke at or before mid
            }
        }
        return numbers[low]
    }
}
