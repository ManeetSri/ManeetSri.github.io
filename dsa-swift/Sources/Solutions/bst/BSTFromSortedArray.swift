// Reference solution: A balanced BST from a sorted array. The middle value becomes the root, so the
// values before it (the left subtree) and after it (the right subtree) differ in number by at most
// one; building each half the same way keeps every node balanced. Passing index bounds instead of
// slicing avoids copying. O(n) time, O(log n) stack.

import DSAKit

public enum BSTFromSortedArray {
    public static func build(_ values: [Int]) -> TreeNode? {
        func build(_ low: Int, _ high: Int) -> TreeNode? {     // the values at low..<high
            guard low < high else { return nil }
            let mid = low + (high - low) / 2
            return TreeNode(values[mid], left: build(low, mid), right: build(mid + 1, high))
        }
        return build(0, values.count)
    }
}
