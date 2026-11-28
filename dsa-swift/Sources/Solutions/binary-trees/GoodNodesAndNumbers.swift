// Reference solution: Good nodes and path numbers. Both pass information down the tree as a parameter:
// the largest value seen on the way from the root, or the number spelled so far. O(n) time, O(h) stack
// space.

import DSAKit

public enum GoodNodesAndNumbers {
    public static func goodNodeCount(_ root: TreeNode?) -> Int {
        func count(_ node: TreeNode?, highestAbove: Int) -> Int {
            guard let node else { return 0 }
            let good = node.value >= highestAbove ? 1 : 0
            let highest = max(highestAbove, node.value)
            return good + count(node.left, highestAbove: highest) + count(node.right, highestAbove: highest)
        }
        return count(root, highestAbove: Int.min)
    }

    public static func pathNumberSum(_ root: TreeNode?) -> Int {
        func sum(_ node: TreeNode?, spelledAbove: Int) -> Int {
            guard let node else { return 0 }
            let number = spelledAbove * 10 + node.value
            if node.left == nil && node.right == nil {
                return number                        // a leaf ends one number
            }
            return sum(node.left, spelledAbove: number) + sum(node.right, spelledAbove: number)
        }
        return sum(root, spelledAbove: 0)
    }
}
