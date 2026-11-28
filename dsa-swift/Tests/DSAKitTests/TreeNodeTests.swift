import Testing
import DSAKit

@Suite struct TreeNodeTests {
    @Test("make and levelOrder round-trip", arguments: [
        [1],
        [3, 9, 20, nil, nil, 15, 7],
        [1, 2, 3, 4, 5, 6, 7],
        [1, nil, 2, nil, 3, nil, 4],
        [5, 4, 8, 11, nil, 13, 4, 7, 2, nil, nil, nil, 1],
        [-1, 0, nil, nil, 1],
    ] as [[Int?]])
    func roundTrip(levelOrder: [Int?]) {
        #expect(TreeNode.make(levelOrder)?.levelOrder == levelOrder)
    }

    @Test("An empty array, or a nil root, is the empty tree")
    func empty() {
        #expect(TreeNode.make([]) == nil)
        #expect(TreeNode.make([nil, 1, 2]) == nil)
    }

    @Test("Trailing nils are optional, and levelOrder leaves them out")
    func trailingNils() {
        #expect(TreeNode.make([1, 2, nil, nil, nil])?.levelOrder == [1, 2])
    }

    @Test("make links children level by level")
    func shape() throws {
        let root = try #require(TreeNode.make([3, 9, 20, nil, nil, 15, 7]))
        #expect(root.value == 3)
        #expect(root.left?.value == 9)
        #expect(root.left?.left == nil && root.left?.right == nil)
        #expect(root.right?.left?.value == 15)
        #expect(root.right?.right?.value == 7)
        #expect(root.description == "[3, 9, 20, nil, nil, 15, 7]")
    }

    @Test("init links children, and changes show up in levelOrder")
    func initialiser() {
        let root = TreeNode(2, left: TreeNode(1), right: TreeNode(3))
        #expect(root.levelOrder == [2, 1, 3])
        root.left?.right = TreeNode(9)
        #expect(root.levelOrder == [2, 1, 3, nil, 9])
    }

    @Test("count, height, inorder and find")
    func measurements() throws {
        let root = try #require(TreeNode.make([5, 3, 8, 1, 4, nil, 9]))
        #expect(root.count == 6)
        #expect(root.height == 3)
        #expect(root.inorder == [1, 3, 4, 5, 8, 9])
        #expect(root.find(4) === root.left?.right)
        #expect(root.find(7) == nil)
        #expect(TreeNode(1).height == 1)
    }

    @Test("A degenerate tree of 200,000 nodes can be built, walked and released")
    func deepTree() {
        var root: TreeNode? = nil
        for value in stride(from: 200_000, through: 1, by: -1) {
            root = TreeNode(value, right: root)
        }
        #expect(root?.height == 200_000)
        #expect(root?.inorder.count == 200_000)
        #expect(root?.find(200_000)?.value == 200_000)
        root = nil
    }

    @Test("Releasing a tree leaves subtrees that are still in use intact")
    func sharedSubtree() throws {
        var root: TreeNode? = TreeNode.make([1, 2, 3, 4, 5])
        let kept = try #require(root?.left)
        root = nil
        #expect(kept.levelOrder == [2, 4, 5])
    }
}
