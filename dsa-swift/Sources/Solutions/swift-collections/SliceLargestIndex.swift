// Reference solution: Where is the largest in the slice? Loop over the slice's own indices, which
// are already the original array's indexes. O(k) time for k elements, O(1) space, no copying.

public enum SliceLargestIndex {
    public static func indexOfLargest(in window: ArraySlice<Int>) -> Int? {
        guard !window.isEmpty else { return nil }
        var best = window.startIndex
        for i in window.indices where window[i] > window[best] {
            best = i
        }
        return best
    }
}
