// Reference solution: Longest rising subsequence. Patience sorting: tails[k] is the smallest reading
// that ends a rising subsequence of length k + 1 so far. The tails stay sorted, so each reading finds
// the first tail that is at least as big with a binary search (the lower bound) and replaces it, or is
// appended if it beats every tail. The number of tails is the answer.
// O(n log n) time, O(n) space.

public enum LongestRisingSubsequence {
    public static func length(of readings: [Int]) -> Int {
        var tails: [Int] = []
        for reading in readings {
            var low = 0
            var high = tails.count
            while low < high {                          // the first tail >= reading
                let mid = low + (high - low) / 2
                if tails[mid] >= reading {
                    high = mid
                } else {
                    low = mid + 1
                }
            }
            if low == tails.count {
                tails.append(reading)
            } else {
                tails[low] = reading
            }
        }
        return tails.count
    }
}
