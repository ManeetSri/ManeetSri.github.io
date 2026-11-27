// Reference solution: Nodes at distance K, and maximum width.
// - values(atDistance:): a tree only links downwards, so first record every node's parent. Then the tree
//   is an undirected graph, and a breadth-first search from the target reaches the nodes k edges away
//   after k rounds. O(n) time and space.
// - maximumWidth: level by level, give each node its position in the level as if the tree were complete
//   (children of position p are 2p and 2p + 1). The width is last − first + 1. Positions are measured
//   from each level's first node, so they stay small however deep the tree is. O(n) time.

import DSAKit

public enum DistanceKAndWidth {
    public static func values(atDistance distance: Int, from target: TreeNode, in root: TreeNode?) -> [Int] {
        var parent: [ObjectIdentifier: TreeNode] = [:]
        var pending: [TreeNode] = root.map { [$0] } ?? []
        while let node = pending.popLast() {
            for child in [node.left, node.right] {
                if let child {
                    parent[ObjectIdentifier(child)] = node
                    pending.append(child)
                }
            }
        }
        var visited: Set<ObjectIdentifier> = [ObjectIdentifier(target)]
        var frontier = [target]                      // every node exactly `step` edges from the target
        var step = 0
        while step < distance && !frontier.isEmpty {
            var next: [TreeNode] = []
            for node in frontier {
                for neighbour in [node.left, node.right, parent[ObjectIdentifier(node)]] {
                    if let neighbour, visited.insert(ObjectIdentifier(neighbour)).inserted {
                        next.append(neighbour)
                    }
                }
            }
            frontier = next
            step += 1
        }
        return frontier.map(\.value).sorted()
    }

    public static func maximumWidth(_ root: TreeNode?) -> Int {
        guard let root else { return 0 }
        var level: [(node: TreeNode, position: Int)] = [(root, 0)]
        var widest = 0
        while let first = level.first, let last = level.last {
            widest = max(widest, last.position - first.position + 1)
            var below: [(node: TreeNode, position: Int)] = []
            for (node, position) in level {
                let offset = position - first.position     // renormalise: the level now starts at 0
                if let left = node.left { below.append((left, 2 * offset)) }
                if let right = node.right { below.append((right, 2 * offset + 1)) }
            }
            level = below
        }
        return widest
    }
}
