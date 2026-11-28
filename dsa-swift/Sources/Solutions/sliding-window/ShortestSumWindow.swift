// Reference solution: Shortest sum window. Grow the window to the right; while its sum reaches the
// target, record its length and shrink it from the left. Every value is positive, so growing only
// raises the sum and shrinking only lowers it. Each index enters and leaves once: O(n) time, O(1) space.

public enum ShortestSumWindow {
    public static func minLength(_ values: [Int], atLeast target: Int) -> Int {
        var left = 0
        var sum = 0
        var best = Int.max
        for right in 0..<values.count {
            sum += values[right]
            while sum >= target {
                best = min(best, right - left + 1)
                sum -= values[left]
                left += 1
            }
        }
        return best == Int.max ? 0 : best
    }
}
