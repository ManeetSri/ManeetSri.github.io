// Reference solution: Vertical columns. Walk the tree once with a queue, recording each node's
// (column, row, value). Sorting those triples puts them in exactly the required order: by column,
// then row, then value, because tuples compare element by element. Then cut the sorted list into
// columns. O(n log n) time for the sort, O(n) space.

import DSAKit

public enum VerticalColumns {
    public static func columns(_ root: TreeNode?) -> [[Int]] {
        guard let root else { return [] }
        var entries: [(column: Int, row: Int, value: Int)] = []
        var queue: [(node: TreeNode, column: Int, row: Int)] = [(root, 0, 0)]
        var head = 0
        while head < queue.count {
            let (node, column, row) = queue[head]
            head += 1
            entries.append((column, row, node.value))
            if let left = node.left { queue.append((left, column - 1, row + 1)) }
            if let right = node.right { queue.append((right, column + 1, row + 1)) }
        }

        entries.sort { ($0.column, $0.row, $0.value) < ($1.column, $1.row, $1.value) }

        var result: [[Int]] = []
        var currentColumn: Int? = nil
        for entry in entries {
            if entry.column != currentColumn {
                result.append([])                     // a new column starts
                currentColumn = entry.column
            }
            result[result.count - 1].append(entry.value)
        }
        return result
    }
}
