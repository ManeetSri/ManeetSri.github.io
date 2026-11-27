// Reference solution: Subarrays with exactly k distinct values. Counting windows with *at most* k
// distinct values is a standard sliding window: for each right end, every left end from `left` to
// `right` works, which is right - left + 1 subarrays. Exactly k is at most k minus at most k - 1.
// O(n) time (two passes), O(k) space.

public enum ExactlyKDistinct {
    public static func count(_ values: [Int], k: Int) -> Int {
        atMost(values, k) - atMost(values, k - 1)
    }

    private static func atMost(_ values: [Int], _ k: Int) -> Int {
        guard k > 0 else { return 0 }
        var counts: [Int: Int] = [:]
        var left = 0
        var total = 0
        for right in 0..<values.count {
            counts[values[right], default: 0] += 1
            while counts.count > k {
                let leaving = values[left]
                counts[leaving, default: 0] -= 1
                if counts[leaving] == 0 {
                    counts[leaving] = nil       // keep counts.count equal to the distinct values
                }
                left += 1
            }
            total += right - left + 1
        }
        return total
    }
}
