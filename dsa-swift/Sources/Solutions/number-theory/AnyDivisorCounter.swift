// Reference solution: Divisible by any of them. Inclusion–exclusion: the numbers up to n divisible by
// every divisor in a subset S are exactly the multiples of lcm(S), and there are n / lcm(S) of them.
// Add the counts for odd-sized subsets and subtract them for even-sized ones. A depth-first search
// builds each subset's lcm from its parent's, a / gcd(a, d) · d, checking the multiplication for
// overflow. Once an lcm passes n, every larger subset in that branch has an lcm at least as big and
// contributes nothing, so the whole branch is skipped. That also keeps every lcm within Int.
// O(2^k · log n) time in the worst case for k divisors, usually far less; O(k) space.

public enum AnyDivisorCounter {
    public static func count(upTo n: Int, divisors: [Int]) -> Int {
        var total = 0
        func explore(from start: Int, lcm: Int, size: Int) {
            for i in start..<divisors.count {
                let d = divisors[i]
                let next = (lcm / gcd(lcm, d)).multipliedReportingOverflow(by: d)
                if next.overflow || next.partialValue > n { continue }   // this branch adds nothing
                total += (size % 2 == 0 ? 1 : -1) * (n / next.partialValue)
                explore(from: i + 1, lcm: next.partialValue, size: size + 1)
            }
        }
        explore(from: 0, lcm: 1, size: 0)
        return total
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var (a, b) = (a, b)
        while b != 0 { (a, b) = (b, a % b) }
        return a
    }
}
