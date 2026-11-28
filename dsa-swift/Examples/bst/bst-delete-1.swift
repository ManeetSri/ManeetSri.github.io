// Generated from src/dsa/content/lessons/bst/bst-delete.mdx. Edit the lesson, then run
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

func insert(_ value: Int, into node: TreeNode?) -> TreeNode {
    guard let node else { return TreeNode(value) }
    if value < node.value {
        node.left = insert(value, into: node.left)
    } else if value > node.value {
        node.right = insert(value, into: node.right)
    }
    return node
}

func remove(_ value: Int, from node: TreeNode?) -> TreeNode? {
    guard let node else { return nil }                    // not in the tree
    if value < node.value {
        node.left = remove(value, from: node.left)
    } else if value > node.value {
        node.right = remove(value, from: node.right)
    } else {
        guard let left = node.left else { return node.right }    // case 1, or case 2 with a right child
        guard let right = node.right else { return left }        // case 2 with a left child
        var successor = right                                    // case 3
        while let smaller = successor.left {
            successor = smaller
        }
        node.value = successor.value
        node.right = remove(successor.value, from: right)
    }
    return node
}

func levels(_ root: TreeNode?) -> String {
    var level = [root].compactMap { $0 }
    var rows: [String] = []
    while !level.isEmpty {
        rows.append(level.map { String($0.value) }.joined(separator: " "))
        level = level.flatMap { [$0.left, $0.right].compactMap { $0 } }
    }
    return rows.joined(separator: " | ")
}

func build() -> TreeNode? {
    var root: TreeNode? = nil
    for value in [50, 30, 70, 20, 40, 60, 80, 35, 45, 65] {
        root = insert(value, into: root)
    }
    return root
}

print("start:    ", levels(build()))
for value in [35, 60, 30, 50, 99] {
    print("remove \(value):", levels(remove(value, from: build())))
}
