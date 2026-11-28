// Reference solution: Best average window. Sum the first k values once, then slide the window one
// step at a time: add the value that enters on the right, subtract the one that leaves on the left.
// Divide only at the end, so every comparison is exact integer arithmetic. O(n) time, O(1) space.

public enum BestAverageWindow {
    public static func maxAverage(_ values: [Int], k: Int) -> Double {
        var windowSum = 0
        for index in 0..<k {
            windowSum += values[index]
        }
        var best = windowSum
        for right in k..<values.count {
            windowSum += values[right] - values[right - k]
            best = max(best, windowSum)
        }
        return Double(best) / Double(k)
    }
}
