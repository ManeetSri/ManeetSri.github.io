// Reference solution: Rebuild a tree from two traversals. The first value of a preorder (or the last of
// a postorder) is the root. Its position in the inorder splits the inorder into the left subtree and the
// right subtree. A dictionary from value to inorder position finds it in O(1), and a moving index walks
// the preorder forwards (or the postorder backwards) as nodes are created. O(n) time and space.

import DSAKit

public enum RebuildFromOrders {
    public static func fromPreorder(_ preorder: [Int], inorder: [Int]) -> TreeNode? {
        var position: [Int: Int] = [:]
        for (index, value) in inorder.enumerated() {
            position[value] = index
        }
        var next = 0                                 // preorder[next] is the next root to place
        // Builds the subtree whose inorder is inorder[low..<high]
        func build(_ low: Int, _ high: Int) -> TreeNode? {
            guard low < high else { return nil }
            let node = TreeNode(preorder[next])
            next += 1
            let middle = position[node.value]!       // every value appears in inorder
            node.left = build(low, middle)           // preorder: the whole left subtree comes next
            node.right = build(middle + 1, high)
            return node
        }
        return build(0, inorder.count)
    }

    public static func fromPostorder(_ postorder: [Int], inorder: [Int]) -> TreeNode? {
        var position: [Int: Int] = [:]
        for (index, value) in inorder.enumerated() {
            position[value] = index
        }
        var next = postorder.count - 1               // read the postorder backwards: root, right, left
        func build(_ low: Int, _ high: Int) -> TreeNode? {
            guard low < high else { return nil }
            let node = TreeNode(postorder[next])
            next -= 1
            let middle = position[node.value]!
            node.right = build(middle + 1, high)     // backwards, the right subtree comes first
            node.left = build(low, middle)
            return node
        }
        return build(0, inorder.count)
    }
}
