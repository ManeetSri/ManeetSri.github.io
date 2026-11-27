// Reference solution: Count a complete tree's nodes. Walk down the leftmost and rightmost edges. If they
// have the same number of levels, the tree is perfect and holds 2^levels − 1 nodes. Otherwise count the
// two subtrees the same way: at least one of them is perfect and answers straight away, so only one
// path down the tree is followed. O(log n) levels, O(log n) each: O(log² n) time.

import DSAKit

public enum CompleteTreeNodeCount {
    public static func count(_ root: TreeNode?) -> Int {
        guard let root else { return 0 }
        var leftLevels = 0
        var node: TreeNode? = root
        while let current = node {
            leftLevels += 1
            node = current.left
        }
        var rightLevels = 0
        node = root
        while let current = node {
            rightLevels += 1
            node = current.right
        }
        if leftLevels == rightLevels {
            return (1 << leftLevels) - 1             // perfect: every level is full
        }
        return 1 + count(root.left) + count(root.right)
    }
}
