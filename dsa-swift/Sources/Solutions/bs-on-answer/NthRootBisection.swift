// Reference solution: Whole and decimal nth roots. Both are binary searches on the answer.
//
// floorRoot: for n ≥ 2 and x ≥ 2, find the first r in 1…x with rⁿ > x (r = x always qualifies), then
// step back one. The power check multiplies one step at a time and stops as soon as the next step would
// pass x, testing `result > x / r` first, so it never overflows. O(n log x) time.
//
// root: bisection on Double between 0 and max(1, x) (roots of numbers below 1 are bigger than the
// number), halving the interval a fixed 100 times. That's always enough: 2¹⁰⁰ is about 10³⁰, and once
// the ends are neighbouring Doubles the midpoint stops changing. O(100 × n) time.

public enum NthRootBisection {
    public static func floorRoot(of x: Int, degree n: Int) -> Int {
        if n == 1 || x < 2 { return x }
        var low = 1
        var high = x                                     // xⁿ > x, so the first r with rⁿ > x is ≤ x
        while low < high {
            let mid = low + (high - low) / 2
            if power(mid, n, exceeds: x) {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low - 1                                   // the last r with rⁿ ≤ x
    }

    public static func root(of x: Double, degree n: Int) -> Double {
        var low = 0.0
        var high = Swift.max(1.0, x)
        for _ in 0..<100 {
            let mid = (low + high) / 2
            var value = 1.0
            for _ in 0..<n { value *= mid }              // may reach infinity, which still compares correctly
            if value >= x {
                high = mid
            } else {
                low = mid
            }
        }
        return (low + high) / 2
    }

    /// True if baseⁿ > limit, for base ≥ 1 and limit ≥ 0, without overflowing.
    private static func power(_ base: Int, _ n: Int, exceeds limit: Int) -> Bool {
        var result = 1
        for _ in 0..<n {
            if result > limit / base { return true }     // result × base would pass limit
            result *= base
        }
        return false
    }
}
