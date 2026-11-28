// Reference solution: Stable partition. One pass asks the predicate about each element once and
// appends it to one of two buffers, which keeps the order inside each group; the array is then
// rebuilt as the first buffer followed by the second. The returned index is the size of the first
// group. O(n) time, O(n) extra space. (swift-algorithms' stablePartition(by:) works in place in
// O(n log n) instead, by partitioning each half and rotating the middle.)

public enum StablePartitionHelper {
    public static func stablePartition<T>(_ items: inout [T], by belongsInSecondPartition: (T) -> Bool) -> Int {
        var first: [T] = []
        var second: [T] = []
        first.reserveCapacity(items.count)
        for item in items {
            if belongsInSecondPartition(item) {
                second.append(item)
            } else {
                first.append(item)
            }
        }
        let pivot = first.count
        first.append(contentsOf: second)
        items = first
        return pivot
    }
}
