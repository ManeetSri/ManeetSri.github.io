import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The four answers for one tree: full, perfect, complete, degenerate.
struct TreeShapesAnswer: Equatable, CustomStringConvertible {
    let full: Bool
    let perfect: Bool
    let complete: Bool
    let degenerate: Bool

    init(_ full: Bool, _ perfect: Bool, _ complete: Bool, _ degenerate: Bool) {
        self.full = full
        self.perfect = perfect
        self.complete = complete
        self.degenerate = degenerate
    }

    init(of root: TreeNode?) {
        self.init(TreeShapes.isFull(root), TreeShapes.isPerfect(root), TreeShapes.isComplete(root), TreeShapes.isDegenerate(root))
    }

    var description: String { "full \(full), perfect \(perfect), complete \(complete), degenerate \(degenerate)" }
}

@Suite struct TreeShapesTests {
    @Test("Small trees", arguments: [
        //                                       full   perfect complete degenerate
        ([1, 2, 3, 4, 5, nil, 6, nil, nil, 7], TreeShapesAnswer(false, false, false, false)),
        ([1, 2, 3, 4, 5, 6, 7], TreeShapesAnswer(true, true, true, false)),
        ([1, 2, 3, 4, 5, 6], TreeShapesAnswer(false, false, true, false)),
        ([1, 2, 3, 4, 5], TreeShapesAnswer(true, false, true, false)),
        ([1, 2, 3, nil, nil, 4, 5], TreeShapesAnswer(true, false, false, false)),
        ([1, 2, 3, 4], TreeShapesAnswer(false, false, true, false)),
        ([1, 2, 3, nil, 4], TreeShapesAnswer(false, false, false, false)),
        ([1, 2, 3], TreeShapesAnswer(true, true, true, false)),
        ([1, 2], TreeShapesAnswer(false, false, true, true)),
        ([1, nil, 2], TreeShapesAnswer(false, false, false, true)),
        ([1, 2, nil, 3], TreeShapesAnswer(false, false, false, true)),
        ([1, nil, 2, 3], TreeShapesAnswer(false, false, false, true)),
        ([1], TreeShapesAnswer(true, true, true, true)),
    ] as [([Int?], TreeShapesAnswer)])
    func small(levelOrder: [Int?], expected: TreeShapesAnswer) {
        #expect(TreeShapesAnswer(of: TreeNode.make(levelOrder)) == expected)
    }

    @Test("The empty tree is every shape")
    func empty() {
        #expect(TreeShapesAnswer(of: nil) == TreeShapesAnswer(true, true, true, true))
    }

    @Test("Perfect needs all leaves on one level, not only two children everywhere")
    func leavesOnOneLevel() {
        // Every node has 0 or 2 children, but the leaves are on levels 2 and 3
        #expect(TreeShapesAnswer(of: TreeNode.make([1, 2, 3, 4, 5])) == TreeShapesAnswer(true, false, true, false))
        // Four levels, perfect
        #expect(TreeShapes.isPerfect(TreeNode.make(Array(1...15))))
        // Fifteen nodes, but not in perfect shape
        #expect(!TreeShapes.isPerfect(TreeNode.make([1, 2, 3, 4, 5, nil, nil, 6, 7, 8, 9, nil, nil, nil, nil, 10, 11, 12, 13, 14, 15])))
    }

    @Test("Large complete and perfect trees")
    func large() {
        // Values 1...n in level order always make a complete tree. It's full exactly when n is odd,
        // and perfect when n is one less than a power of two.
        #expect(TreeShapesAnswer(of: TreeNode.make(Array(1...131_071))) == TreeShapesAnswer(true, true, true, false))
        #expect(TreeShapesAnswer(of: TreeNode.make(Array(1...131_070))) == TreeShapesAnswer(false, false, true, false))
        #expect(TreeShapesAnswer(of: TreeNode.make(Array(1...100_000))) == TreeShapesAnswer(false, false, true, false))
        #expect(TreeShapesAnswer(of: TreeNode.make(Array(1...99_999))) == TreeShapesAnswer(true, false, true, false))
    }

    @Test("A single gap near the end of 100,000 nodes breaks completeness")
    func gapNearEnd() {
        let levelOrder: [Int?] = Array(1...99_998) + [nil, 99_999]
        #expect(TreeShapesAnswer(of: TreeNode.make(levelOrder)) == TreeShapesAnswer(false, false, false, false))
    }

    @Test("Long chains and a long caterpillar")
    func deep() {
        // A zigzag chain 500 levels deep
        var chain: [Int?] = [1]
        for value in 2...500 {
            chain += value % 2 == 0 ? [value, nil] : [nil, value]
        }
        #expect(TreeShapesAnswer(of: TreeNode.make(chain)) == TreeShapesAnswer(false, false, false, true))
        // A spine going right, with a leaf hanging to the left of each spine node: full, not complete
        var caterpillar: [Int?] = [1]
        for k in 0..<499 {
            caterpillar += [2 * k + 2, 2 * k + 3, nil, nil]
        }
        #expect(TreeShapesAnswer(of: TreeNode.make(caterpillar)) == TreeShapesAnswer(true, false, false, false))
    }
}
