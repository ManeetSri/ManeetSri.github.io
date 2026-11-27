// Reference solution: Read off the growth. The Master theorem for T(n) = a·T(n/b) + n^d·log^k n compares
// a with b^d. The comparison is done with whole numbers, multiplying b in while the power stays at most a,
// which never overflows and never suffers floating-point rounding. Only the leaves case needs a Double,
// for the exponent log_b(a). O(d) time.

import Foundation

public enum RecurrenceGrowthReader {
    public static func solve(a: Int, b: Int, d: Int, k: Int) -> (exponent: Double, logPower: Int) {
        // Find whether b^d is less than, equal to or greater than a, stopping once it passes a
        var power = 1
        var exceeds = false
        for _ in 0..<d {
            if power > a / b {                 // power · b would be greater than a
                exceeds = true
                break
            }
            power *= b
        }
        if exceeds || power > a {
            return (Double(d), k)              // a < b^d: the root wins
        }
        if power == a {
            return (Double(d), k + 1)          // a = b^d: every level ties, one more log
        }
        return (log(Double(a)) / log(Double(b)), 0)   // a > b^d: the leaves win
    }
}
