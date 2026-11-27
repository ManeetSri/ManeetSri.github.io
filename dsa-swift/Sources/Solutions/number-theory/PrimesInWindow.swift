// Reference solution: Primes in a far-off window. A segmented sieve. Every composite up to `high` has a
// prime factor at most √high, at most 10⁶ here, so sieve those base primes normally first. Then keep
// one flag per number of the window and, for each base prime p, cross out its multiples inside the
// window, starting at the larger of p² and the first multiple of p at or above `low`. Starting at p²
// never crosses out p itself, and 1 is removed by hand.
// O(√high · log log high + (high − low) · log log high) time, O(√high + (high − low)) space.
// The hot loops are `while` loops: in a debug build, which is what `swift test` makes, they run about
// twice as fast as `for … in stride`.

public enum PrimesInWindow {
    public static func primes(from low: Int, through high: Int) -> [Int] {
        let root = integerSquareRoot(high)
        var isPrime = Array(repeating: true, count: high - low + 1)
        for p in basePrimes(upTo: root) {
            var multiple = max(p * p, (low + p - 1) / p * p)    // never p itself
            while multiple <= high {
                isPrime[multiple - low] = false
                multiple += p
            }
        }
        if low == 1 { isPrime[0] = false }
        var primes: [Int] = []
        for offset in isPrime.indices where isPrime[offset] {
            primes.append(low + offset)
        }
        return primes
    }

    /// ⌊√n⌋, starting from the floating-point estimate and correcting it in whole numbers.
    private static func integerSquareRoot(_ n: Int) -> Int {
        var r = Int(Double(n).squareRoot())
        while r * r > n { r -= 1 }
        while (r + 1) * (r + 1) <= n { r += 1 }
        return r
    }

    /// The Sieve of Eratosthenes up to n.
    private static func basePrimes(upTo n: Int) -> [Int] {
        guard n >= 2 else { return [] }
        var isPrime = Array(repeating: true, count: n + 1)
        isPrime[0] = false
        isPrime[1] = false
        var p = 2
        while p * p <= n {
            if isPrime[p] {
                var multiple = p * p
                while multiple <= n {
                    isPrime[multiple] = false
                    multiple += p
                }
            }
            p += 1
        }
        return isPrime.indices.filter { isPrime[$0] }
    }
}
