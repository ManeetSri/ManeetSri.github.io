// Reference solution: How tall will the ticket tree get? A new value's parent is its predecessor or its
// successor among the values inserted so far, whichever is deeper, so depth(x) = 1 + the larger of
// their depths. To find those neighbours, link all values in sorted order and unlink them in reverse
// insertion order: just before x is unlinked, its list neighbours are exactly the earlier-inserted
// predecessor and successor. O(n log n) time for the sort, O(n) space.

public enum InsertionOrderHeight {
    public static func height(afterInserting values: [Int]) -> Int {
        let n = values.count
        guard n > 0 else { return 0 }
        // rank[i] is the position of values[i] in sorted order
        let byValue = values.indices.sorted { values[$0] < values[$1] }
        var rank = [Int](repeating: 0, count: n)
        for (position, index) in byValue.enumerated() { rank[index] = position }

        // A doubly linked list of ranks; -1 means "no neighbour"
        var previous = Array(-1..<(n - 1))
        var next = Array(1...n)
        next[n - 1] = -1

        // Remove in reverse insertion order: the neighbours left are the ones inserted earlier
        var predecessor = [Int](repeating: -1, count: n)
        var successor = [Int](repeating: -1, count: n)
        for index in stride(from: n - 1, through: 0, by: -1) {
            let r = rank[index]
            predecessor[r] = previous[r]
            successor[r] = next[r]
            if previous[r] >= 0 { next[previous[r]] = next[r] }
            if next[r] >= 0 { previous[next[r]] = previous[r] }
        }

        // Forward: the parent is the deeper neighbour
        var depth = [Int](repeating: 0, count: n)                // by rank; 0 = not inserted yet
        var height = 0
        for index in 0..<n {
            let r = rank[index]
            let below = max(predecessor[r] >= 0 ? depth[predecessor[r]] : 0,
                            successor[r] >= 0 ? depth[successor[r]] : 0)
            depth[r] = below + 1
            height = max(height, depth[r])
        }
        return height
    }
}
