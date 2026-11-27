import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BSTValidateTests {
    /// A balanced BST holding `values` (sorted), middle value at the root.
    static func balanced(_ values: [Int]) -> TreeNode? {
        func build(_ low: Int, _ high: Int) -> TreeNode? {
            guard low < high else { return nil }
            let mid = (low + high) / 2
            return TreeNode(values[mid], left: build(low, mid), right: build(mid + 1, high))
        }
        return build(0, values.count)
    }

    @Test("Valid trees", arguments: [
        [2, 1, 3],
        [40, 20, 60, 10, 30, 50, 70, nil, 15, nil, nil, 45],
        [1, nil, 2, nil, 3, nil, 4],
        [4, 3, nil, 2, nil, 1],
        [8, 3, 10, 1, 6, nil, 14, nil, nil, 4, 7, 13],
        [-5, -10, 0],
    ] as [[Int?]])
    func valid(levelOrder: [Int?]) {
        #expect(BSTValidate.isValid(TreeNode.make(levelOrder)))
    }

    @Test("Each child is on the correct side of its parent, but a grandchild breaks the rule", arguments: [
        [10, 5, 15, nil, nil, 6, 20],                    // 6 is in 10's right subtree
        [10, 5, 15, 2, 12],                              // 12 is in 10's left subtree
        [20, 10, 30, 5, 15, 25, 35, nil, nil, 12, 21],   // 21, deep in the left subtree
        [5, 1, 8, nil, nil, 4, 9],
    ] as [[Int?]])
    func grandchildBreaks(levelOrder: [Int?]) {
        #expect(!BSTValidate.isValid(TreeNode.make(levelOrder)))
    }

    @Test("A child on the wrong side of its parent", arguments: [
        [2, 3, 1],
        [5, 1, 4],
        [1, nil, 0],
    ] as [[Int?]])
    func wrongSide(levelOrder: [Int?]) {
        #expect(!BSTValidate.isValid(TreeNode.make(levelOrder)))
    }

    @Test("Equal values make the tree invalid", arguments: [
        [2, 2],
        [2, nil, 2],
        [5, 3, 8, nil, 5],
        [5, 3, 8, 3],
    ] as [[Int?]])
    func duplicates(levelOrder: [Int?]) {
        #expect(!BSTValidate.isValid(TreeNode.make(levelOrder)))
    }

    @Test("The empty tree and a single node are valid")
    func tiny() {
        #expect(BSTValidate.isValid(nil))
        #expect(BSTValidate.isValid(TreeNode(0)))
    }

    @Test("Int.min and Int.max are real values, not missing bounds", arguments: [
        ([Int.min], true),
        ([Int.max], true),
        ([0, Int.min, Int.max], true),
        ([Int.max, Int.min], true),
        ([Int.min, nil, Int.max], true),
        ([Int.min, Int.min], false),
        ([Int.max, nil, Int.max], false),
        ([0, Int.min, Int.max, nil, nil, Int.min], false),
        ([0, Int.min, Int.max, nil, Int.max], false),
    ] as [([Int?], Bool)])
    func extremes(levelOrder: [Int?], expected: Bool) {
        #expect(BSTValidate.isValid(TreeNode.make(levelOrder)) == expected)
    }

    @Test("A chain of 1,000 nodes, valid until a leaf at the bottom breaks an ancestor's bound")
    func chain() {
        let root = TreeNode(0)
        var last = root
        for value in 1..<1_000 {
            let node = TreeNode(value)
            last.right = node
            last = node
        }
        var results = [BSTValidate.isValid(root)]
        for value in [998, 500, Int.min] {
            last.left = TreeNode(value)                  // smaller than its parent, 999, but not bigger than 998
            results.append(BSTValidate.isValid(root))
        }
        last.left = nil
        results.append(BSTValidate.isValid(root))
        #expect(results == [true, false, false, false, true])
    }

    @Test("A balanced tree of 131,071 nodes, then one leaf that breaks the root's bound")
    func large() throws {
        let n = 131_071
        let root = try #require(Self.balanced(Array(0..<n)))
        let validAtFirst = BSTValidate.isValid(root)
        #expect(validAtFirst)
        // The smallest value in the root's right subtree is a leaf: the left child of its parent.
        var node = try #require(root.right)
        while let left = node.left {
            node = left
        }
        let original = node.value
        node.value = root.value - 1                      // still smaller than its parent
        let validBelowRoot = BSTValidate.isValid(root)
        node.value = root.value
        let validEqualToRoot = BSTValidate.isValid(root)
        node.value = original
        let validAgain = BSTValidate.isValid(root)
        #expect(!validBelowRoot)
        #expect(!validEqualToRoot)
        #expect(validAgain)
    }
}
