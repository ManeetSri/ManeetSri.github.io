// Reference solution: Parallel merge sort. Small arrays are sorted directly, because a child task
// costs far more than sorting a few elements. Larger arrays are copied into two halves, each half is
// sorted in its own child task, and the parent merges the two results. Each child owns its copy, and
// results come back as return values, so no memory is shared. The group's results can arrive in
// either order, so each is tagged with which half it is.
// O(n log n) work in total; with enough cores, the final O(n) merge at the top is the longest
// sequential step. O(n log n) space over the whole recursion from the copies (O(n) live at a time per
// level).

public enum TaskGroupMergeSort {
    public static func merge(_ first: [Int], _ second: [Int]) -> [Int] {
        var result: [Int] = []
        result.reserveCapacity(first.count + second.count)
        var i = 0
        var j = 0
        while i < first.count && j < second.count {
            if second[j] < first[i] {
                result.append(second[j])
                j += 1
            } else {
                result.append(first[i])
                i += 1
            }
        }
        result.append(contentsOf: first[i...])
        result.append(contentsOf: second[j...])
        return result
    }

    public static func sorted(_ items: [Int], threshold: Int) async -> [Int] {
        if items.count <= max(threshold, 1) {
            return items.sorted()
        }
        let middle = items.count / 2
        let left = Array(items[..<middle])
        let right = Array(items[middle...])
        return await withTaskGroup(of: (isLeft: Bool, sorted: [Int]).self) { group in
            group.addTask { (true, await TaskGroupMergeSort.sorted(left, threshold: threshold)) }
            group.addTask { (false, await TaskGroupMergeSort.sorted(right, threshold: threshold)) }
            var sortedLeft: [Int] = []
            var sortedRight: [Int] = []
            for await half in group {
                if half.isLeft {
                    sortedLeft = half.sorted
                } else {
                    sortedRight = half.sorted
                }
            }
            return merge(sortedLeft, sortedRight)
        }
    }
}
