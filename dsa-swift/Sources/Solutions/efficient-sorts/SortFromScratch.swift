// Reference solution: Sort without sort(). Top-down merge sort: sort each half recursively, then
// merge the halves. One buffer, made once, is shared by every merge. If the halves are already in
// order across the middle, the merge is skipped, so sorted input costs O(n). O(n log n) time in
// every case, O(n) extra space, and O(log n) recursion depth.

public enum SortFromScratch {
    public static func sorted(_ numbers: [Int]) -> [Int] {
        var items = numbers
        var buffer = numbers                             // scratch space for every merge
        mergeSort(&items, &buffer, 0, items.count)
        return items
    }

    /// Sorts items[low..<high].
    private static func mergeSort(_ items: inout [Int], _ buffer: inout [Int], _ low: Int, _ high: Int) {
        guard high - low > 1 else { return }
        let mid = low + (high - low) / 2
        mergeSort(&items, &buffer, low, mid)
        mergeSort(&items, &buffer, mid, high)
        if items[mid - 1] <= items[mid] { return }       // already in order: nothing to merge
        for index in low..<high {
            buffer[index] = items[index]
        }
        var left = low
        var right = mid
        for write in low..<high {
            if right == high || (left < mid && buffer[left] <= buffer[right]) {
                items[write] = buffer[left]              // ties take the left value: stable
                left += 1
            } else {
                items[write] = buffer[right]
                right += 1
            }
        }
    }
}
