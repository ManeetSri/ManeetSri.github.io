import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BSTDeleteNodeTests {
    /// 50 at the root; 30 and 70; 20, 40, 60 and 80; then 35 and 45 under 40, 65 right of 60 and 75
    /// left of 80.
    static let sample: [Int?] = [50, 30, 70, 20, 40, 60, 80, nil, nil, 35, 45, nil, 65, 75]

    /// A balanced BST holding `values` (sorted), middle value at the root.
    static func balanced(_ values: [Int]) -> TreeNode? {
        func build(_ low: Int, _ high: Int) -> TreeNode? {
            guard low < high else { return nil }
            let mid = (low + high) / 2
            return TreeNode(values[mid], left: build(low, mid), right: build(mid + 1, high))
        }
        return build(0, values.count)
    }

    @Test("Removes a leaf, a node with one child, or a node with two children", arguments: [
        20, 35, 45, 65, 75,                              // leaves
        60, 80,                                          // one child: right only, left only
        30, 40, 70,                                      // two children
        50,                                              // the root, with two children
    ])
    func removesEachKind(value: Int) throws {
        let root = try #require(TreeNode.make(Self.sample))
        let before = root.inorder
        let height = root.height
        let result = BSTDeleteNode.remove(value, from: root)
        #expect(result?.inorder == before.filter { $0 != value })
        #expect((result?.height ?? 0) <= height)
    }

    @Test("Removing a leaf or a one-child node splices it out", arguments: [
        (20, [50, 30, 70, nil, 40, 60, 80, 35, 45, nil, 65, 75]),
        (60, [50, 30, 70, 20, 40, 65, 80, nil, nil, 35, 45, nil, nil, 75]),
        (80, [50, 30, 70, 20, 40, 60, 75, nil, nil, 35, 45, nil, 65]),
    ] as [(Int, [Int?])])
    func exactShapes(value: Int, expected: [Int?]) {
        #expect(BSTDeleteNode.remove(value, from: TreeNode.make(Self.sample))?.levelOrder == expected)
    }

    @Test("A value that isn't there leaves the tree unchanged", arguments: [10, 33, 55, 90])
    func missing(value: Int) throws {
        let root = try #require(TreeNode.make(Self.sample))
        let result = BSTDeleteNode.remove(value, from: root)
        #expect(result === root)
        #expect(result?.levelOrder == Self.sample)
    }

    @Test("Empty, single-node and two-node trees")
    func tiny() {
        #expect(BSTDeleteNode.remove(1, from: nil) == nil)
        #expect(BSTDeleteNode.remove(1, from: TreeNode(1)) == nil)
        #expect(BSTDeleteNode.remove(2, from: TreeNode(1))?.levelOrder == [1])
        #expect(BSTDeleteNode.remove(2, from: TreeNode.make([2, 1]))?.levelOrder == [1])
        #expect(BSTDeleteNode.remove(2, from: TreeNode.make([2, nil, 3]))?.levelOrder == [3])
        #expect(BSTDeleteNode.remove(3, from: TreeNode.make([2, nil, 3]))?.levelOrder == [2])
    }

    @Test("Removing every value, in several orders, ends with the empty tree", arguments: [
        [50, 30, 70, 20, 40, 60, 80, 35, 45, 65, 75],
        [20, 35, 45, 65, 75, 30, 60, 80, 40, 70, 50],
        [75, 65, 45, 35, 20, 80, 70, 60, 50, 40, 30],
    ])
    func removeEverything(order: [Int]) {
        var root = TreeNode.make(Self.sample)
        var remaining = order.sorted()
        for value in order {
            root = BSTDeleteNode.remove(value, from: root)
            remaining.removeAll { $0 == value }
            #expect((root?.inorder ?? []) == remaining)
        }
        #expect(root == nil)
    }

    @Test("Extreme values")
    func extremes() {
        let root = TreeNode.make([0, Int.min, Int.max])
        #expect(BSTDeleteNode.remove(0, from: root)?.inorder == [Int.min, Int.max])
    }

    @Test("Removing 30,000 values from a balanced tree of 131,071 nodes")
    func large() {
        let n = 131_071
        var root = Self.balanced(Array(0..<n))
        var removed = Set<Int>()
        var value = 0
        for _ in 0..<30_000 {
            value = (value + 7_919) % n                  // jumps all over the tree
            if removed.insert(value).inserted {
                root = BSTDeleteNode.remove(value, from: root)
            }
        }
        let correct = root?.inorder == (0..<n).filter { !removed.contains($0) }
        #expect(correct)
        #expect((root?.height ?? 0) <= 17)
    }
}
