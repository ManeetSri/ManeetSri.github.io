// Reference solution: Integer square root. Binary search for the largest r with r × r ≤ x. Squaring
// mid could overflow for large x, so the test is written as mid <= x / mid, which means the same thing
// for positive integers and never overflows. O(log x) time, O(1) space.

public enum IntegerSquareRoot {
    public static func floorRoot(of x: Int) -> Int {
        if x < 2 {
            return x                             // 0 and 1 are their own roots
        }
        var low = 1
        var high = x / 2                         // for x ≥ 2, the root is at most x / 2
        while low <= high {
            let mid = low + (high - low) / 2
            if mid <= x / mid {
                low = mid + 1                    // mid × mid ≤ x: mid is a candidate, look higher
            } else {
                high = mid - 1                   // mid × mid > x: too big
            }
        }
        return high                              // the last value that passed
    }
}
