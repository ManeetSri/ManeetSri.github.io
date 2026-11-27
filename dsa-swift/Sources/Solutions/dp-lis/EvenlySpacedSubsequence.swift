// Reference solution: Longest evenly spaced subsequence. ending[i][d] is the longest arithmetic
// subsequence that ends at index i with difference d, kept as one dictionary per index because only
// the differences that occur are stored. Each pair j < i with d = values[i] - values[j] extends the
// run ending at j with that difference, or starts a new run of two.
// O(n²) time and space.

public enum EvenlySpacedSubsequence {
    public static func longest(_ values: [Int]) -> Int {
        guard values.count > 2 else { return values.count }
        var ending = Array(repeating: [Int: Int](), count: values.count)
        var best = 2
        for i in values.indices {
            for j in 0..<i {
                let step = values[i] - values[j]
                let length = ending[j][step, default: 1] + 1
                if length > ending[i][step, default: 0] {
                    ending[i][step] = length
                }
                best = max(best, length)
            }
        }
        return best
    }
}
