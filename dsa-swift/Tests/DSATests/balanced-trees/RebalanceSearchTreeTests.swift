import DSAKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RebalanceSearchTreeTests {
    /// The height of every subtree if each node is height-balanced, or nil as soon as one isn't.
    /// Only called once the tree is known to be shallow, so the recursion stays short.
    private func balancedHeight(_ node: TreeNode?) -> Int? {
        guard let node else { return 0 }
        guard let left = balancedHeight(node.left), let right = balancedHeight(node.right),
              abs(left - right) <= 1 else { return nil }
        return 1 + max(left, right)
    }

    /// True when `result` is a height-balanced BST holding exactly `values` (sorted, distinct).
    private func check(_ result: TreeNode?, holds values: [Int]) -> Bool {
        guard let result else { return values.isEmpty }
        // A balanced tree of 100,000 nodes is at most 24 levels tall; check that first (iteratively),
        // so a lopsided answer fails here instead of overflowing the stack below.
        guard result.height <= 30 else { return false }
        return result.inorder == values && balancedHeight(result) != nil
    }

    /// A chain where each node's only child is on the right: the BST you get from sorted inserts.
    private func rightChain(_ values: [Int]) -> TreeNode? {
        guard let first = values.first else { return nil }
        let root = TreeNode(first)
        var tail = root
        for value in values.dropFirst() {
            tail.right = TreeNode(value)
            tail = tail.right!
        }
        return root
    }

    @Test("Examples from the statement", arguments: [
        ([1, nil, 2, nil, 3, nil, 4] as [Int?], [1, 2, 3, 4]),
        ([5, 4, nil, 3, nil, 2, nil, 1], [1, 2, 3, 4, 5]),
        ([2, 1, 3], [1, 2, 3]),
        ([10, 5, nil, nil, 8, 6], [5, 6, 8, 10]),
    ])
    func examples(levelOrder: [Int?], values: [Int]) {
        #expect(check(RebalanceSearchTree.balanced(TreeNode.make(levelOrder)), holds: values))
    }

    @Test("The empty tree and a single node")
    func tiny() {
        #expect(RebalanceSearchTree.balanced(nil) == nil)
        let single = RebalanceSearchTree.balanced(TreeNode(7))
        #expect(single?.value == 7)
        #expect(single?.left == nil && single?.right == nil)
    }

    @Test("A tree that's already balanced stays a valid balanced BST")
    func alreadyBalanced() {
        let tree = TreeNode.make([8, 4, 12, 2, 6, 10, 14, 1, 3, 5, 7, 9, 11, 13, 15])
        #expect(check(RebalanceSearchTree.balanced(tree), holds: Array(1...15)))
    }

    @Test("Zigzag chains and negative values", arguments: [
        [-50, nil, 40, -30, nil, nil, 20, -10, nil, nil, 0] as [Int?],
        [0, -100, nil, nil, -50, -75, nil, nil, -60],
    ])
    func zigzag(levelOrder: [Int?]) {
        let tree = TreeNode.make(levelOrder)
        let values = tree?.inorder ?? []
        #expect(check(RebalanceSearchTree.balanced(tree), holds: values))
    }

    @Test("Every chain length up to 64")
    func everyLength() {
        var failures: [Int] = []
        for n in 0...64 {
            let values = Array(0..<n).map { $0 * 3 }
            if !check(RebalanceSearchTree.balanced(rightChain(values)), holds: values) {
                failures.append(n)
            }
        }
        #expect(failures == [])
    }

    @Test("A chain of 100,000 nodes, too deep to recurse down")
    func longChain() {
        let values = Array(0..<100_000)
        let result = RebalanceSearchTree.balanced(rightChain(values))
        #expect(check(result, holds: values))
    }

    @Test("A long zigzag of 50,000 nodes")
    func longZigzag() {
        // Each node's child alternates sides, closing in on the middle value: 0, 49999, 1, 49998, …
        let n = 50_000
        var order: [Int] = []
        var low = 0
        var high = n - 1
        while low <= high {
            order.append(low)
            if low != high { order.append(high) }
            low += 1
            high -= 1
        }
        let root = TreeNode(order[0])
        var tail = root
        for value in order.dropFirst() {
            let node = TreeNode(value)
            if value < tail.value { tail.left = node } else { tail.right = node }
            tail = node
        }
        #expect(check(RebalanceSearchTree.balanced(root), holds: Array(0..<n)))
    }
}
