// Reference solution: Maximum subarray sum. Kadane's algorithm: `current` is the best sum of a run
// ending at this element, which either extends the previous run or starts afresh here. Starting
// from the first element (not 0) handles all-negative arrays. O(n) time, O(1) space.

public enum MaximumSubarraySum {
    public static func bestSum(in numbers: [Int]) -> Int {
        var current = numbers[0]
        var best = numbers[0]
        for number in numbers.dropFirst() {
            current = max(number, current + number)
            best = max(best, current)
        }
        return best
    }
}
