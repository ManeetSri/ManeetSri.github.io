import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// Each level's values left to right, worked out with a queue of (node, depth) pairs.
private func referenceLevels(_ root: TreeNode?) -> [[Int]] {
    var result: [[Int]] = []
    var queue: [(TreeNode, Int)] = root.map { [($0, 0)] } ?? []
    var head = 0
    while head < queue.count {
        let (node, depth) = queue[head]
        head += 1
        if depth == result.count { result.append([]) }
        result[depth].append(node.value)
        if let left = node.left { queue.append((left, depth + 1)) }
        if let right = node.right { queue.append((right, depth + 1)) }
    }
    return result
}

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

@Suite struct ZigzagSideViewsTests {
    @Test("Zigzag", arguments: [
        ([1, 2, 3, 4, 5, nil, 6, nil, nil, 7], [[1], [3, 2], [4, 5, 6], [7]]),
        ([3, 9, 20, nil, nil, 15, 7], [[3], [20, 9], [15, 7]]),
        ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], [[1], [3, 2], [4, 5, 6, 7], [15, 14, 13, 12, 11, 10, 9, 8]]),
        ([1, nil, 2, nil, 3], [[1], [2], [3]]),
        ([5], [[5]]),
    ] as [([Int?], [[Int]])])
    func zigzag(levelOrder: [Int?], expected: [[Int]]) {
        #expect(ZigzagSideViews.zigzag(TreeNode.make(levelOrder)) == expected)
    }

    @Test("Right and left views", arguments: [
        ([1, 2, 3, 4, 5, nil, 6, nil, nil, 7], [1, 3, 6, 7], [1, 2, 4, 7]),
        ([3, 9, 20, nil, nil, 15, 7], [3, 20, 7], [3, 9, 15]),
        // The right view can see a node on the left side when the right side is shorter
        ([1, 2, 3, 4], [1, 3, 4], [1, 2, 4]),
        ([1, 2, 3, nil, 5, nil, 4], [1, 3, 4], [1, 2, 5]),
        ([1, nil, 2, nil, 3], [1, 2, 3], [1, 2, 3]),
        ([1, 2, nil, 3], [1, 2, 3], [1, 2, 3]),
        ([-1, -2, -3, nil, nil, -4, nil, nil, -5], [-1, -3, -4, -5], [-1, -2, -4, -5]),
        ([8], [8], [8]),
    ] as [([Int?], [Int], [Int])])
    func views(levelOrder: [Int?], right: [Int], left: [Int]) {
        let root = TreeNode.make(levelOrder)
        #expect(ZigzagSideViews.rightView(root) == right)
        #expect(ZigzagSideViews.leftView(root) == left)
    }

    @Test("The empty tree")
    func empty() {
        #expect(ZigzagSideViews.zigzag(nil) == [])
        #expect(ZigzagSideViews.rightView(nil) == [])
        #expect(ZigzagSideViews.leftView(nil) == [])
    }

    @Test("A bushy tree of 100,000 nodes with gaps")
    func largeBushy() {
        var levelOrder: [Int?] = [0]
        var nodes = 1
        var index = 1
        while nodes < 100_000 {
            if index % 5 == 2 || index % 13 == 7 {
                levelOrder.append(nil)
            } else {
                levelOrder.append(index)
                nodes += 1
            }
            index += 1
        }
        let root = TreeNode.make(levelOrder)
        let levels = referenceLevels(root)
        #expect(firstDifference(ZigzagSideViews.zigzag(root), levels.enumerated().map { $0 % 2 == 0 ? $1 : Array($1.reversed()) }) == nil)
        #expect(firstDifference(ZigzagSideViews.rightView(root), levels.map { $0.last! }) == nil)
        #expect(firstDifference(ZigzagSideViews.leftView(root), levels.map { $0.first! }) == nil)
    }

    @Test("A chain 100,000 nodes deep")
    func largeChain() {
        let root = TreeNode(0)
        var current = root
        for value in 1..<100_000 {
            let next = TreeNode(value)
            if value % 4 == 0 { current.left = next } else { current.right = next }
            current = next
        }
        let all = Array(0..<100_000)
        #expect(firstDifference(ZigzagSideViews.rightView(root), all) == nil)
        #expect(firstDifference(ZigzagSideViews.leftView(root), all) == nil)
        #expect(firstDifference(ZigzagSideViews.zigzag(root), all.map { [$0] }) == nil)
    }
}
