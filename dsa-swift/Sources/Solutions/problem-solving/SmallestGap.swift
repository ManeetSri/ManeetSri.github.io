// Reference solution: Smallest gap. Sort, then only neighbours can be closest. O(n log n) time, O(n)
// space. The brute force over every pair, O(n²), is also fast enough for n ≤ 2,000.

public enum SmallestGap {
    public static func smallestGap(in numbers: [Int]) -> Int {
        let sorted = numbers.sorted()
        var smallest = Int.max
        for i in 1..<sorted.count {
            smallest = min(smallest, sorted[i] - sorted[i - 1])
        }
        return smallest
    }
}
