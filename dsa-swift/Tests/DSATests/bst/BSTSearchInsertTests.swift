import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BSTSearchInsertTests {
    /// 40 at the root; 20 and 60; 10, 30, 50 and 70; then 15 (right of 10) and 45 (left of 50).
    static let sample: [Int?] = [40, 20, 60, 10, 30, 50, 70, nil, 15, nil, nil, 45]

    /// A balanced BST holding `values` (sorted), middle value at the root.
    static func balanced(_ values: [Int]) -> TreeNode? {
        func build(_ low: Int, _ high: Int) -> TreeNode? {
            guard low < high else { return nil }
            let mid = (low + high) / 2
            return TreeNode(values[mid], left: build(low, mid), right: build(mid + 1, high))
        }
        return build(0, values.count)
    }

    @Test("search finds the node holding each value", arguments: [40, 20, 60, 10, 30, 50, 70, 15, 45])
    func searchFinds(target: Int) throws {
        let root = try #require(TreeNode.make(Self.sample))
        let found = BSTSearchInsert.search(target, in: root)
        #expect(found?.value == target)
        #expect(found === root.find(target))
    }

    @Test("search returns nil for missing values", arguments: [5, 12, 18, 25, 35, 42, 48, 55, 65, 80, Int.min, Int.max])
    func searchMissing(target: Int) {
        #expect(BSTSearchInsert.search(target, in: TreeNode.make(Self.sample)) == nil)
    }

    @Test("search in the empty tree and in one node")
    func searchTiny() {
        #expect(BSTSearchInsert.search(1, in: nil) == nil)
        let single = TreeNode(7)
        #expect(BSTSearchInsert.search(7, in: single) === single)
        #expect(BSTSearchInsert.search(8, in: single) == nil)
    }

    @Test("insert adds a new leaf in the only place it can go", arguments: [
        (35, [40, 20, 60, 10, 30, 50, 70, nil, 15, nil, 35, 45]),
        (5, [40, 20, 60, 10, 30, 50, 70, 5, 15, nil, nil, 45]),
        (80, [40, 20, 60, 10, 30, 50, 70, nil, 15, nil, nil, 45, nil, nil, 80]),
        (47, [40, 20, 60, 10, 30, 50, 70, nil, 15, nil, nil, 45, nil, nil, nil, nil, nil, nil, 47]),
        (12, [40, 20, 60, 10, 30, 50, 70, nil, 15, nil, nil, 45, nil, nil, nil, 12]),
    ] as [(Int, [Int?])])
    func insertLeaf(value: Int, expected: [Int?]) throws {
        let root = try #require(TreeNode.make(Self.sample))
        let result = BSTSearchInsert.insert(value, into: root)
        #expect(result === root)
        #expect(result.levelOrder == expected)
    }

    @Test("Inserting a value that's already there changes nothing", arguments: [40, 15, 45, 70])
    func insertDuplicate(value: Int) throws {
        let root = try #require(TreeNode.make(Self.sample))
        let result = BSTSearchInsert.insert(value, into: root)
        #expect(result === root)
        #expect(result.levelOrder == Self.sample)
    }

    @Test("Inserting into the empty tree makes a single node")
    func insertIntoEmpty() {
        let result = BSTSearchInsert.insert(9, into: nil)
        #expect(result.levelOrder == [9])
        #expect(result.left == nil && result.right == nil)
    }

    @Test("Inserting one value at a time builds the tree", arguments: [
        ([50, 30, 70, 20, 40, 60, 80], [50, 30, 70, 20, 40, 60, 80]),
        ([3, 1, 2], [3, 1, nil, nil, 2]),
        ([1, 2, 3], [1, nil, 2, nil, 3]),
        ([0, Int.min, Int.max, -1, 1], [0, Int.min, Int.max, nil, -1, 1]),
        ([5, 5, 3, 3, 8], [5, 3, 8]),
    ] as [([Int], [Int?])])
    func buildByInserting(values: [Int], expected: [Int?]) {
        var root: TreeNode? = nil
        for value in values {
            root = BSTSearchInsert.insert(value, into: root)
        }
        #expect(root?.levelOrder == expected)
    }

    @Test("A chain of 1,000 nodes from sorted insertions")
    func chain() {
        var root: TreeNode? = nil
        for value in 1...1_000 {
            root = BSTSearchInsert.insert(value, into: root)
        }
        #expect(root?.height == 1_000)
        #expect(BSTSearchInsert.search(1_000, in: root)?.value == 1_000)
        #expect(BSTSearchInsert.search(1_001, in: root) == nil)
    }

    @Test("Searches and insertions in a balanced tree of 131,071 nodes")
    func large() throws {
        let n = 131_071                                  // 2^17 − 1: a perfect tree, 17 levels
        let root = try #require(Self.balanced((0..<n).map { $0 * 2 }))
        var wrong = 0
        for target in stride(from: 0, to: 2 * n, by: 7) {
            let found = BSTSearchInsert.search(target, in: root)
            if target % 2 == 0 ? found?.value != target : found != nil {
                wrong += 1
            }
        }
        #expect(wrong == 0)
        var inserted: [Int] = []
        var newRoots = 0
        for odd in stride(from: 1, to: 2 * n, by: 26) {        // odd values only
            if BSTSearchInsert.insert(odd, into: root) !== root {
                newRoots += 1
            }
            inserted.append(odd)
        }
        #expect(newRoots == 0)
        #expect(root.height == 18)
        let sorted = root.inorder == ((0..<n).map { $0 * 2 } + inserted).sorted()
        #expect(sorted)
    }
}
