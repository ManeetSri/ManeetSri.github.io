// Reference solution: Level order in and out. Both directions walk the tree level by level with a
// queue (an array and a head index, so taking from the front is O(1)).
// - build: every node created joins the queue; each parent taken from the front consumes the next
//   two entries as its left and right children.
// - levelOrder: queue optional nodes; a real node writes its value and queues both children, a nil
//   writes nil. Then drop the trailing nils.
// Both are O(n) time and O(n) space.

import DSAKit

public enum LevelOrderBuilder {
    public static func build(_ levelOrder: [Int?]) -> TreeNode? {
        guard let first = levelOrder.first, let rootValue = first else { return nil }
        let root = TreeNode(rootValue)
        var parents = [root]                      // nodes waiting for their children
        var head = 0
        var index = 1                             // the next entry to read
        while index < levelOrder.count && head < parents.count {
            let parent = parents[head]
            head += 1
            if let value = levelOrder[index] {
                let child = TreeNode(value)
                parent.left = child
                parents.append(child)
            }
            index += 1
            if index < levelOrder.count, let value = levelOrder[index] {
                let child = TreeNode(value)
                parent.right = child
                parents.append(child)
            }
            index += 1
        }
        return root
    }

    public static func levelOrder(_ root: TreeNode?) -> [Int?] {
        guard let root else { return [] }
        var result: [Int?] = []
        var queue: [TreeNode?] = [root]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            if let node {
                result.append(node.value)
                queue.append(node.left)
                queue.append(node.right)
            } else {
                result.append(nil)
            }
        }
        while let last = result.last, last == nil {
            result.removeLast()
        }
        return result
    }
}
