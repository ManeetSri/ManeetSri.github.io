// Reference solution: Traversals without recursion. Each keeps the unfinished work in an array used as
// a stack, so depth costs heap memory rather than call-stack frames: O(n) time and O(h) extra space.
// - Preorder: pop a node, visit it, push its right child and then its left, so the left comes off first.
// - Inorder: slide down the left edge pushing nodes; pop one, visit it, then do the same from its right child.
// - Postorder: the same slide, but a node is only visited once its right subtree is finished. `lastVisited`
//   tells the two times we look at a node apart: coming up from the left (go right next) or from the
//   right (visit it).

import DSAKit

public enum StackTraversals {
    public static func preorder(_ root: TreeNode?) -> [Int] {
        var result: [Int] = []
        var stack = [root].compactMap { $0 }
        while let node = stack.popLast() {
            result.append(node.value)
            if let right = node.right { stack.append(right) }
            if let left = node.left { stack.append(left) }
        }
        return result
    }

    public static func inorder(_ root: TreeNode?) -> [Int] {
        var result: [Int] = []
        var stack: [TreeNode] = []
        var current = root
        while current != nil || !stack.isEmpty {
            while let node = current {                // everything down the left edge waits its turn
                stack.append(node)
                current = node.left
            }
            let node = stack.removeLast()             // its left subtree is done
            result.append(node.value)
            current = node.right
        }
        return result
    }

    public static func postorder(_ root: TreeNode?) -> [Int] {
        var result: [Int] = []
        var stack: [TreeNode] = []
        var current = root
        var lastVisited: TreeNode? = nil
        while current != nil || !stack.isEmpty {
            while let node = current {
                stack.append(node)
                current = node.left
            }
            let top = stack[stack.count - 1]          // left subtree done; what about the right?
            if let right = top.right, right !== lastVisited {
                current = right                       // not started yet: go and do it
            } else {
                result.append(top.value)              // no right subtree, or just finished it
                lastVisited = top
                stack.removeLast()
            }
        }
        return result
    }
}
