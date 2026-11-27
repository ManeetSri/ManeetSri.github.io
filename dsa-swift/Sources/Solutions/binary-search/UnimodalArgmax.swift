// Reference solution: Best price in the fewest runs. Binary search on the slope: compare profit(mid) with
// profit(mid + 1). Rising means the peak is to the right of mid; falling means it's mid or to its left.
// Each pair of evaluations halves the range, about 2 log₂ n in total, against ternary search's
// 3.4 log₂ n. O(log n) time, O(1) space.

public enum UnimodalArgmax {
    public static func peak(in range: ClosedRange<Int>, profit: (Int) -> Int) -> Int {
        var low = range.lowerBound
        var high = range.upperBound
        while low < high {
            let mid = low + (high - low) / 2             // mid < high, so mid + 1 is in range
            if profit(mid) < profit(mid + 1) {
                low = mid + 1                            // still rising: the peak is to the right
            } else {
                high = mid                               // falling: mid or something left of it
            }
        }
        return low
    }
}
