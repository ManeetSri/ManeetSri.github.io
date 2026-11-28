import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// Where two long arrays first differ, so a failing test doesn't print 100,000 values.
private func firstDifference<T: Equatable>(_ actual: [T], _ expected: [T]) -> String? {
    guard actual != expected else { return nil }
    let index = actual.indices.first { $0 >= expected.count || actual[$0] != expected[$0] } ?? actual.count
    func show(_ values: [T]) -> String {
        guard index < values.count else { return "nothing" }
        let text = "\(values[index])"
        return text.count > 80 ? text.prefix(80) + "…" : text
    }
    let got = show(actual)
    let wanted = show(expected)
    return "\(actual.count) values instead of \(expected.count); first difference at index \(index): got \(got), expected \(wanted)"
}

@Suite struct LevelOrderBuilderTests {
    static let cases: [[Int?]] = [
        [1, 2, 3, 4, 5, nil, 6, nil, nil, 7],
        [3, 9, 20, nil, nil, 15, 7],
        [1, 2, 3, 4, 5, 6, 7],
        [1, nil, 2, nil, 3, nil, 4],
        [1, 2, nil, 3, nil, 4],
        [5, 4, 8, 11, nil, 13, 4, 7, 2, nil, nil, nil, 1],
        [-1, 0, nil, nil, -7],
        [10, 10, 10],
        [42],
    ]

    @Test("build makes the tree the array describes", arguments: cases)
    func builds(levelOrder: [Int?]) {
        #expect(LevelOrderBuilder.build(levelOrder)?.levelOrder == levelOrder)
    }

    @Test("levelOrder writes the tree back out", arguments: cases)
    func writes(levelOrder: [Int?]) {
        #expect(LevelOrderBuilder.levelOrder(TreeNode.make(levelOrder)) == levelOrder)
    }

    @Test("build links children to the right parents")
    func shape() throws {
        let root = try #require(LevelOrderBuilder.build([3, 9, 20, nil, nil, 15, 7]))
        #expect(root.value == 3)
        #expect(root.left?.value == 9)
        #expect(root.left?.left == nil && root.left?.right == nil)
        #expect(root.right?.value == 20)
        #expect(root.right?.left?.value == 15)
        #expect(root.right?.right?.value == 7)
    }

    @Test("Empty input, and a nil root, are the empty tree")
    func empty() {
        #expect(LevelOrderBuilder.build([]) == nil)
        #expect(LevelOrderBuilder.build([nil]) == nil)
        #expect(LevelOrderBuilder.build([nil, 1, 2]) == nil)
        #expect(LevelOrderBuilder.levelOrder(nil) == [])
    }

    @Test("Trailing nils are optional in, and left out")
    func trailingNils() {
        #expect(LevelOrderBuilder.build([1, 2, nil, nil, nil])?.levelOrder == [1, 2])
        #expect(LevelOrderBuilder.build([1, nil, nil])?.levelOrder == [1])
        // A node built with init, whose last level ends in a missing right child
        let root = TreeNode(1, left: TreeNode(2, left: TreeNode(4)), right: TreeNode(3))
        #expect(LevelOrderBuilder.levelOrder(root) == [1, 2, 3, 4])
    }

    @Test("A missing node has no entries for its children")
    func noEntriesUnderGaps() {
        // 1's left is missing, so the next pair of entries belongs to 2, not to the missing node
        let root = LevelOrderBuilder.build([1, nil, 2, 3, 4])
        #expect(root?.right?.left?.value == 3)
        #expect(root?.right?.right?.value == 4)
        #expect(LevelOrderBuilder.levelOrder(root) == [1, nil, 2, 3, 4])
    }

    @Test("100,000 nodes in a complete tree")
    func largeComplete() {
        let levelOrder: [Int?] = Array(1...100_000)
        #expect(firstDifference(LevelOrderBuilder.build(levelOrder)?.levelOrder ?? [], levelOrder) == nil)
        #expect(firstDifference(LevelOrderBuilder.levelOrder(TreeNode.make(levelOrder)), levelOrder) == nil)
    }

    @Test("A chain 100,000 nodes deep, both ways")
    func largeChain() {
        var levelOrder: [Int?] = [0]
        for value in 1..<100_000 {
            levelOrder += value % 3 == 0 ? [value, nil] : [nil, value]
        }
        while levelOrder.last == .some(nil) {
            levelOrder.removeLast()
        }
        let built = LevelOrderBuilder.build(levelOrder)
        #expect(built?.count == 100_000)
        #expect(built?.height == 100_000)
        #expect(firstDifference(built?.levelOrder ?? [], levelOrder) == nil)
        #expect(firstDifference(LevelOrderBuilder.levelOrder(TreeNode.make(levelOrder)), levelOrder) == nil)
    }

    @Test("A bushy tree with gaps scattered through it")
    func largeWithGaps() {
        // Each node's children are present unless a simple rule knocks one out
        var levelOrder: [Int?] = [0]
        var nodes = 1
        var index = 1
        while nodes < 100_000 {
            if index % 7 == 3 || index % 11 == 5 {
                levelOrder.append(nil)
            } else {
                levelOrder.append(index)
                nodes += 1
            }
            index += 1
        }
        let built = LevelOrderBuilder.build(levelOrder)
        #expect(built?.count == 100_000)
        #expect(firstDifference(built?.levelOrder ?? [], levelOrder) == nil)
        #expect(firstDifference(LevelOrderBuilder.levelOrder(TreeNode.make(levelOrder)), levelOrder) == nil)
    }
}
