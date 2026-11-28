// Reference solution: Find a peak. Compare the middle height with its right neighbour. If the ground
// rises to the right, keep climbing right: the heights can't rise for ever, and the edge counts as
// lower, so a peak lies beyond mid. Otherwise mid itself or something to its left is a peak. The
// range [low, high] always contains a peak, and it halves each step. O(log n) time, O(1) space.

public enum PeakFinder {
    public static func peakIndex(in heights: [Int]) -> Int {
        var low = 0
        var high = heights.count - 1
        while low < high {
            let mid = low + (high - low) / 2     // mid < high, so mid + 1 is a valid index
            if heights[mid] < heights[mid + 1] {
                low = mid + 1                    // uphill to the right
            } else {
                high = mid                       // downhill: mid could be the peak
            }
        }
        return low
    }
}
