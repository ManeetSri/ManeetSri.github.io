// Reference solution: Subarray sums in a band. With prefix sums P (P[0] = 0), the subarray
// values[i..<j] sums to P[j] − P[i], so it's in the band exactly when P[j] − high ≤ P[i] ≤ P[j] − low.
// Scan j from left to right, keeping a Fenwick tree of the earlier prefix sums counted by rank among
// all n + 1 prefix sums (coordinate compression). Two binary searches turn the band into a range of
// ranks, and one range count finds the matching earlier prefixes. O(n log n) time, O(n) space.

public enum SubarraySumsInBand {
    public static func count(_ values: [Int], low: Int, high: Int) -> Int {
        guard low <= high else { return 0 }
        var prefix = [0]
        for value in values {
            prefix.append(prefix.last! + value)
        }
        let sorted = Array(Set(prefix)).sorted()

        /// The number of distinct prefix sums less than x: a lower bound.
        func countBelow(_ x: Int) -> Int {
            var lo = 0, hi = sorted.count
            while lo < hi {
                let mid = (lo + hi) / 2
                if sorted[mid] < x { lo = mid + 1 } else { hi = mid }
            }
            return lo
        }

        var tree = Array(repeating: 0, count: sorted.count + 1)   // counts by rank, 1-indexed
        func add(_ rank: Int) {
            var i = rank
            while i < tree.count {
                tree[i] += 1
                i += i & -i
            }
        }
        func countUpTo(_ rank: Int) -> Int {                       // earlier prefixes with rank <= rank
            var i = rank, total = 0
            while i > 0 {
                total += tree[i]
                i -= i & -i
            }
            return total
        }

        var total = 0
        for p in prefix {
            // Earlier prefixes in p − high ... p − low have ranks countBelow(p − high) + 1 through
            // countBelow(p − low + 1)
            total += countUpTo(countBelow(p - low + 1)) - countUpTo(countBelow(p - high))
            add(countBelow(p) + 1)
        }
        return total
    }
}
