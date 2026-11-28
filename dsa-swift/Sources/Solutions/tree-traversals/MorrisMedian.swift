// Reference solution: Median of a BST in constant space. A BST's inorder is sorted, and a Morris walk
// visits it with O(1) extra space. The first walk counts the n nodes; the second records the values at
// positions (n - 1) / 2 and n / 2. Each walk runs to the end, so every thread it makes is removed and
// the tree comes back unchanged. O(n) time, O(1) extra space.

import DSAKit

public enum MorrisMedian {
    public static func median(of root: TreeNode?) -> Double? {
        var count = 0
        walkInorder(root) { _ in count += 1 }
        guard count > 0 else { return nil }
        var position = 0
        var lower = 0
        var upper = 0
        walkInorder(root) { value in
            if position == (count - 1) / 2 { lower = value }
            if position == count / 2 { upper = value }
            position += 1                                    // keep walking: the threads must go
        }
        return (Double(lower) + Double(upper)) / 2
    }

    /// A complete Morris inorder walk: O(n) time, O(1) extra space, and the tree is restored.
    private static func walkInorder(_ root: TreeNode?, _ visit: (Int) -> Void) {
        var current = root
        while let node = current {
            guard let left = node.left else {
                visit(node.value)                            // nothing on the left: visit, go right
                current = node.right
                continue
            }
            var predecessor = left                           // rightmost node of the left subtree
            while let next = predecessor.right, next !== node {
                predecessor = next
            }
            if predecessor.right == nil {
                predecessor.right = node                     // first arrival: leave a thread back
                current = left
            } else {
                predecessor.right = nil                      // back via the thread: remove it, visit
                visit(node.value)
                current = node.right
            }
        }
    }
}
