// Reference solution: The widest gap. Pigeonhole buckets: n values spread from low to high have an
// average gap of (high − low) / (n − 1), so the widest gap is at least that. Make buckets narrower
// than that, and no two values in the same bucket can be the widest gap: the answer is always
// between one non-empty bucket's largest value and the next non-empty bucket's smallest.
// Each bucket only needs its smallest and largest value. O(n) time, O(n) space.

public enum WidestGap {
    public static func widestGap(in numbers: [Int]) -> Int {
        guard numbers.count > 1, let low = numbers.min(), let high = numbers.max(), low < high else {
            return 0
        }
        // Bucket width ≤ the average gap, rounded down, and at least 1. Two values in one bucket
        // differ by at most width − 1, which is less than the widest gap.
        let width = max(1, (high - low) / (numbers.count - 1))
        let bucketCount = (high - low) / width + 1
        var smallest = [Int?](repeating: nil, count: bucketCount)
        var largest = [Int?](repeating: nil, count: bucketCount)
        for value in numbers {
            let bucket = (value - low) / width
            smallest[bucket] = min(smallest[bucket] ?? value, value)
            largest[bucket] = max(largest[bucket] ?? value, value)
        }
        // Walk the non-empty buckets in order, measuring each jump from one to the next
        var widest = 0
        var previousLargest = low
        for bucket in 0..<bucketCount {
            guard let bucketSmallest = smallest[bucket], let bucketLargest = largest[bucket] else { continue }
            widest = max(widest, bucketSmallest - previousLargest)
            previousLargest = bucketLargest
        }
        return widest
    }
}
