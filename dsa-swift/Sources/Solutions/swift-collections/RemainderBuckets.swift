// Reference solution: Remainder buckets.
// Swift's % keeps the sign of the left side (-7 % 3 == -1), so add k and take % again
// to land in 0..<k. Dictionary(grouping:by:) keeps each bucket in input order.
// O(n) time, O(n) extra space.

public enum RemainderBuckets {
    public static func buckets(_ numbers: [Int], k: Int) -> [Int: [Int]] {
        Dictionary(grouping: numbers) { (($0 % k) + k) % k }
    }
}
