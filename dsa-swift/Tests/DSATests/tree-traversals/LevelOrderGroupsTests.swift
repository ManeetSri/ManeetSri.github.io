import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Node = LevelOrderGroups.Node

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

@Suite struct LevelOrderGroupsTests {
    @Test("Binary trees, top down", arguments: [
        ([1, 2, 3, 4, 5, nil, 6, nil, nil, 7], [[1], [2, 3], [4, 5, 6], [7]]),
        ([3, 9, 20, nil, nil, 15, 7], [[3], [9, 20], [15, 7]]),
        ([1, 2, 3, 4, 5, 6, 7], [[1], [2, 3], [4, 5, 6, 7]]),
        ([1, nil, 2, nil, 3], [[1], [2], [3]]),
        ([1, 2, nil, nil, 3, 4], [[1], [2], [3], [4]]),
        ([4, -2, 7, -2, nil, nil, 7], [[4], [-2, 7], [-2, 7]]),
        ([1, 2, 3, nil, 4, 5, nil, nil, 6, 7], [[1], [2, 3], [4, 5], [6, 7]]),
        ([9], [[9]]),
    ] as [([Int?], [[Int]])])
    func topDown(levelOrder: [Int?], expected: [[Int]]) {
        #expect(LevelOrderGroups.levels(TreeNode.make(levelOrder)) == expected)
    }

    @Test("Bottom up keeps each level left to right")
    func bottomUp() {
        #expect(LevelOrderGroups.levelsBottomUp(TreeNode.make([1, 2, 3, 4, 5, nil, 6, nil, nil, 7])) == [[7], [4, 5, 6], [2, 3], [1]])
        #expect(LevelOrderGroups.levelsBottomUp(TreeNode.make([3, 9, 20, nil, nil, 15, 7])) == [[15, 7], [9, 20], [3]])
        #expect(LevelOrderGroups.levelsBottomUp(TreeNode(1)) == [[1]])
    }

    @Test("The empty tree has no levels")
    func empty() {
        #expect(LevelOrderGroups.levels(nil) == [])
        #expect(LevelOrderGroups.levelsBottomUp(nil) == [])
        #expect(LevelOrderGroups.naryLevels(nil) == [])
    }

    @Test("N-ary trees")
    func nary() {
        // 1 has children 2, 3 and 4; 2 has 5 and 6; 4 has 7; 6 has 8, 9, 10 and 11
        let root = Node(1, children: [
            Node(2, children: [Node(5), Node(6, children: [Node(8), Node(9), Node(10), Node(11)])]),
            Node(3),
            Node(4, children: [Node(7)]),
        ])
        #expect(LevelOrderGroups.naryLevels(root) == [[1], [2, 3, 4], [5, 6, 7], [8, 9, 10, 11]])
        #expect(LevelOrderGroups.naryLevels(Node(0)) == [[0]])
        let wide = Node(0, children: (1...20).map { Node($0) })
        #expect(LevelOrderGroups.naryLevels(wide) == [[0], Array(1...20)])
    }

    @Test("A complete tree of 100,000 nodes")
    func largeComplete() {
        let n = 100_000
        let groups = LevelOrderGroups.levels(TreeNode.make(Array(1...n)))
        // Level d holds 2^d ... 2^(d+1) - 1, and the last level is cut short at n
        var expected: [[Int]] = []
        var start = 1
        while start <= n {
            expected.append(Array(start...min(2 * start - 1, n)))
            start *= 2
        }
        #expect(firstDifference(groups, expected) == nil)
        #expect(firstDifference(LevelOrderGroups.levelsBottomUp(TreeNode.make(Array(1...n))), expected.reversed()) == nil)
    }

    @Test("A chain 100,000 nodes deep")
    func largeChain() {
        let root = TreeNode(0)
        var current = root
        for value in 1..<100_000 {
            let next = TreeNode(value)
            if value % 2 == 0 { current.left = next } else { current.right = next }
            current = next
        }
        let groups = LevelOrderGroups.levels(root)
        #expect(groups.count == 100_000)
        #expect(firstDifference(groups, (0..<100_000).map { [$0] }) == nil)
    }

    @Test("An N-ary tree of 100,001 nodes")
    func largeNary() {
        let root = Node(0, children: (0..<1_000).map { i in
            Node(i + 1, children: (0..<99).map { j in Node(1_001 + i * 99 + j) })
        })
        #expect(firstDifference(LevelOrderGroups.naryLevels(root), [[0], Array(1...1_000), Array(1_001...100_000)]) == nil)
    }
}
