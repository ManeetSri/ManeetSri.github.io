import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TreeCensusTests {
    // 1 has children 2 and 3; 2 has 4 and 5; 5 has a left child 7; 3 has a right child 6
    static let example: [Int?] = [1, 2, 3, 4, 5, nil, 6, nil, nil, 7]

    @Test("Size and leaves", arguments: [
        (example, 7, 3),
        ([8, 3, 10, 1, 6, nil, 14, nil, nil, 4, 7, 13], 9, 4),
        ([1, 2, 3, 4, 5, 6, 7], 7, 4),
        ([1, nil, 2, nil, 3, nil, 4], 4, 1),
        ([5, 4], 2, 1),
        ([5, nil, 4], 2, 1),
        ([42], 1, 1),
    ] as [([Int?], Int, Int)])
    func sizeAndLeaves(levelOrder: [Int?], size: Int, leaves: Int) {
        let root = TreeNode.make(levelOrder)
        #expect(TreeCensus.size(root) == size)
        #expect(TreeCensus.leaves(root) == leaves)
    }

    @Test("Depth of each node in the running example", arguments: [
        (1, 0), (2, 1), (3, 1), (4, 2), (5, 2), (6, 2), (7, 3),
    ])
    func depths(value: Int, expected: Int) {
        #expect(TreeCensus.depth(of: value, in: TreeNode.make(Self.example)) == expected)
    }

    @Test("Missing values have no depth")
    func missing() {
        let root = TreeNode.make(Self.example)
        for value in [0, 8, -1, 100] {
            #expect(TreeCensus.depth(of: value, in: root) == nil)
        }
    }

    @Test("The empty tree")
    func empty() {
        #expect(TreeCensus.size(nil) == 0)
        #expect(TreeCensus.leaves(nil) == 0)
        #expect(TreeCensus.depth(of: 1, in: nil) == nil)
    }

    @Test("Negative values, and a value deep on the right")
    func negatives() {
        let root = TreeNode.make([-5, -3, 0, nil, nil, -1, 9, nil, nil, nil, -8])
        #expect(TreeCensus.size(root) == 6)
        #expect(TreeCensus.leaves(root) == 3)
        #expect(TreeCensus.depth(of: -8, in: root) == 3)
        #expect(TreeCensus.depth(of: -3, in: root) == 1)
    }

    @Test("A perfect tree of 131,071 nodes")
    func largePerfect() {
        // Values 1...n in level order: the node holding i has children 2i and 2i + 1, and its depth
        // is one less than the number of binary digits in i
        let n = 131_071
        let root = TreeNode.make(Array(1...n))
        #expect(TreeCensus.size(root) == n)
        #expect(TreeCensus.leaves(root) == 65_536)
        #expect(TreeCensus.depth(of: 1, in: root) == 0)
        #expect(TreeCensus.depth(of: 65_536, in: root) == 16)
        #expect(TreeCensus.depth(of: n, in: root) == 16)
        #expect(TreeCensus.depth(of: 1_000, in: root) == 9)
        #expect(TreeCensus.depth(of: n + 1, in: root) == nil)
    }

    @Test("A chain 500 levels deep")
    func chain() {
        var levelOrder: [Int?] = [1]
        for value in 2...500 {
            levelOrder += value % 2 == 0 ? [value, nil] : [nil, value]
        }
        let root = TreeNode.make(levelOrder)
        #expect(TreeCensus.size(root) == 500)
        #expect(TreeCensus.leaves(root) == 1)
        #expect(TreeCensus.depth(of: 500, in: root) == 499)
    }
}
