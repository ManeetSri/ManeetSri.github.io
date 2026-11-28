// Generated from src/dsa/content/lessons/binary-trees/bt-distance-k-width.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func values(atDistance k: Int, from target: TreeNode, in root: TreeNode) -> [Int] {
    // 1. Every node's parent, so the search can go up as well as down
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
    // 2. Breadth-first search from the target, one distance per round
    var visited: Set<ObjectIdentifier> = [ObjectIdentifier(target)]
    var frontier = [target]                             // every node at the current distance
    var distance = 0
    while distance < k && !frontier.isEmpty {
        var next: [TreeNode] = []
        for node in frontier {
            for neighbour in [node.left, node.right, parent[ObjectIdentifier(node)]] {
                if let neighbour, visited.insert(ObjectIdentifier(neighbour)).inserted {
                    next.append(neighbour)
                }
            }
        }
        frontier = next
        distance += 1
    }
    return frontier.map(\.value).sorted()
}

let tree = TreeNode.make([7, 3, 9, 1, 5, nil, 12, nil, nil, 4, 6])!
let five = tree.left!.right!
for k in 0...5 {
    print("distance \(k) from 5:", values(atDistance: k, from: five, in: tree))
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
