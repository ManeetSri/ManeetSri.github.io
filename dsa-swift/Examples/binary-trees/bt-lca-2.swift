// Generated from src/dsa/content/lessons/binary-trees/bt-lca.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func parents(of root: TreeNode) -> [ObjectIdentifier: TreeNode] {
    var parent: [ObjectIdentifier: TreeNode] = [:]
    var pending = [root]
    while let node = pending.popLast() {
        for child in [node.left, node.right] {
            if let child {
                parent[ObjectIdentifier(child)] = node
                pending.append(child)
            }
        }
    }
    return parent
}

func climbingLCA(_ p: TreeNode, _ q: TreeNode, parent: [ObjectIdentifier: TreeNode]) -> TreeNode {
    var ancestors: Set<ObjectIdentifier> = []
    var node: TreeNode? = p
    while let current = node {                          // p and everything above it
        ancestors.insert(ObjectIdentifier(current))
        node = parent[ObjectIdentifier(current)]
    }
    var climber = q
    while !ancestors.contains(ObjectIdentifier(climber)) {
        climber = parent[ObjectIdentifier(climber)]!    // the root is in the set, so this stops
    }
    return climber
}

let tree = TreeNode.make([10, 4, 7, 1, 9, nil, 3, nil, nil, 5, 8])!
let parent = parents(of: tree)
for (p, q) in [(5, 8), (5, 1), (5, 3), (9, 8)] {
    print("LCA of \(p) and \(q):", climbingLCA(tree.find(p)!, tree.find(q)!, parent: parent).value)
}

// MARK: - The TreeNode from DSAKit, cut down so this file runs on its own

final class TreeNode {
    var value: Int
    var left: TreeNode?
    var right: TreeNode?

    init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }

    /// The first node holding value, searching level by level, like find in DSAKit
    func find(_ value: Int) -> TreeNode? {
        var queue = [self]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            if node.value == value { return node }
            if let left = node.left { queue.append(left) }
            if let right = node.right { queue.append(right) }
        }
        return nil
    }

    /// Builds a tree from its level order, with nil for a missing child, like TreeNode.make in DSAKit
    static func make(_ levelOrder: [Int?]) -> TreeNode? {
        guard let first = levelOrder.first, let rootValue = first else { return nil }
        let root = TreeNode(rootValue)
        var parents = [root]
        var head = 0
        var index = 1
        while index < levelOrder.count && head < parents.count {
            let parent = parents[head]
            head += 1
            if let value = levelOrder[index] {
                parent.left = TreeNode(value)
                parents.append(parent.left!)
            }
            index += 1
            if index < levelOrder.count, let value = levelOrder[index] {
                parent.right = TreeNode(value)
                parents.append(parent.right!)
            }
            index += 1
        }
        return root
    }
}
