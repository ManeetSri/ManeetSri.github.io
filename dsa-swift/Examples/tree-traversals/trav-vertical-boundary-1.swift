// Generated from src/dsa/content/lessons/tree-traversals/trav-vertical-boundary.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TreeNode {
    var value: Int
    var left: TreeNode?
    var right: TreeNode?

    init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }
}

// Every node's (column, row, value), met in level order
func cells(_ root: TreeNode?) -> [(column: Int, row: Int, value: Int)] {
    guard let root else { return [] }
    var result: [(column: Int, row: Int, value: Int)] = []
    var queue: [(node: TreeNode, column: Int, row: Int)] = [(root, 0, 0)]
    var head = 0
    while head < queue.count {
        let (node, column, row) = queue[head]
        head += 1
        result.append((column, row, node.value))
        if let left = node.left { queue.append((left, column - 1, row + 1)) }
        if let right = node.right { queue.append((right, column + 1, row + 1)) }
    }
    return result
}

// Cut a list already in column order into one array per column
func group(_ sorted: [(column: Int, row: Int, value: Int)]) -> [[Int]] {
    var columns: [[Int]] = []
    var current: Int? = nil
    for cell in sorted {
        if cell.column != current {
            columns.append([])
            current = cell.column
        }
        columns[columns.count - 1].append(cell.value)
    }
    return columns
}

func verticalSortedTies(_ root: TreeNode?) -> [[Int]] {
    group(cells(root).sorted { ($0.column, $0.row, $0.value) < ($1.column, $1.row, $1.value) })
}

func verticalLevelOrderTies(_ root: TreeNode?) -> [[Int]] {
    // Sort by column, then by position in level order, which already has rows and ties in order
    var indexed = Array(cells(root).enumerated())
    indexed.sort { ($0.element.column, $0.offset) < ($1.element.column, $1.offset) }
    return group(indexed.map(\.element))
}

let root = TreeNode(1,
                    left: TreeNode(2, left: TreeNode(4), right: TreeNode(5, left: TreeNode(7))),
                    right: TreeNode(3, right: TreeNode(6)))
print(verticalSortedTies(root))

// 9 (under 3) and 2 (under 5) share column 0 and row 2
let tied = TreeNode(8, left: TreeNode(3, right: TreeNode(9)), right: TreeNode(5, left: TreeNode(2)))
print("sorted ties:     ", verticalSortedTies(tied))
print("level-order ties:", verticalLevelOrderTies(tied))
