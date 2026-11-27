import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The sideways drawing of `root`, one string per line: reverse inorder, 4 spaces per level. Written
/// with an explicit stack, so deep trees are fine.
private func drawing(_ root: TreeNode?) -> [String] {
    var lines: [String] = []
    var stack: [(TreeNode, Int)] = []
    var current = root
    var depth = 0
    while current != nil || !stack.isEmpty {
        while let node = current {                           // slide right: the right subtree prints first
            stack.append((node, depth))
            current = node.right
            depth += 1
        }
        let (node, nodeDepth) = stack.removeLast()
        lines.append(String(repeating: " ", count: 4 * nodeDepth) + String(node.value))
        current = node.left
        depth = nodeDepth + 1
    }
    return lines
}

/// A binary search tree of `count` pseudo-random values (the same every run), inserted with a loop.
private func randomTree(count: Int, seed: UInt64) -> TreeNode? {
    var state = seed
    var root: TreeNode? = nil
    for _ in 0..<count {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        let value = Int(state >> 33) % 2_000_000 - 1_000_000
        guard var node = root else {
            root = TreeNode(value)
            continue
        }
        while true {
            if value < node.value {
                guard let left = node.left else { node.left = TreeNode(value); break }
                node = left
            } else {
                guard let right = node.right else { node.right = TreeNode(value); break }
                node = right
            }
        }
    }
    return root
}

/// Where two long arrays first differ, so a failing test doesn't print 100,000 values.
private func firstDifference<T: Equatable>(_ actual: [T], _ expected: [T]) -> String? {
    guard actual != expected else { return nil }
    let index = actual.indices.first { $0 >= expected.count || actual[$0] != expected[$0] } ?? actual.count
    let got = index < actual.count ? "\(actual[index])" : "nothing"
    let wanted = index < expected.count ? "\(expected[index])" : "nothing"
    return "\(actual.count) values instead of \(expected.count); first difference at index \(index): got \(got), expected \(wanted)"
}

@Suite struct SidewaysTreeReaderTests {
    @Test("The lesson's drawing")
    func lessonDrawing() {
        let lines = [
            "        6",
            "    3",
            "1",
            "        5",
            "            7",
            "    2",
            "        4",
        ]
        #expect(SidewaysTreeReader.tree(fromLines: lines)?.levelOrder == [1, 2, 3, 4, 5, nil, 6, nil, nil, 7])
    }

    @Test("Small drawings", arguments: [
        (["    20", "10"], [10, nil, 20] as [Int?]),
        (["10", "    -4"], [10, -4]),
        (["42"], [42]),
        (["    3", "2", "    1"], [2, 1, 3]),
        (["            4", "        3", "    2", "1"], [1, nil, 2, nil, 3, nil, 4]),
        (["1", "    2", "        3"], [1, 2, nil, 3]),
        (["    -1000000007", "123456789"], [123_456_789, nil, -1_000_000_007]),
    ])
    func small(lines: [String], expected: [Int?]) {
        #expect(SidewaysTreeReader.tree(fromLines: lines)?.levelOrder == expected)
    }

    @Test("No lines is the empty tree")
    func empty() {
        #expect(SidewaysTreeReader.tree(fromLines: []) == nil)
    }

    @Test("Round trip: drawing then reading gives the same tree", arguments: [
        [1, 2, 3, 4, 5, 6, 7],
        [5, 4, 8, 11, nil, 13, 4, 7, 2, nil, nil, nil, 1],
        [1, 2, nil, nil, 3, 4, nil, nil, 5],
        [0, 0, 0, nil, 0, 0],
        [-5, -6, 7, nil, nil, -8, 9, 10],
        [1, 2, 3, nil, 4, nil, 5, nil, 6, nil, 7],
    ] as [[Int?]])
    func roundTrip(levelOrder: [Int?]) {
        let lines = drawing(TreeNode.make(levelOrder))
        #expect(SidewaysTreeReader.tree(fromLines: lines)?.levelOrder == levelOrder, "\(lines)")
    }

    @Test("Hundreds of random small trees")
    func manyRandom() {
        var failures: [String] = []
        for seed in 1...300 {
            let tree = randomTree(count: Int(seed % 20) + 1, seed: UInt64(seed))
            let lines = drawing(tree)
            let rebuilt = SidewaysTreeReader.tree(fromLines: lines)
            if rebuilt?.levelOrder != tree?.levelOrder && failures.count < 3 {
                failures.append("\(lines)")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("A zigzag chain 1,000 levels deep")
    func deepZigzag() {
        let root = TreeNode(0)
        var node = root
        for value in 1..<1_000 {
            let child = TreeNode(value)
            if value % 2 == 0 { node.left = child } else { node.right = child }
            node = child
        }
        let rebuilt = SidewaysTreeReader.tree(fromLines: drawing(root))
        #expect(firstDifference(rebuilt?.levelOrder ?? [], root.levelOrder) == nil)
    }

    @Test("A random tree of 50,000 nodes")
    func large() {
        let tree = randomTree(count: 50_000, seed: 34)
        let rebuilt = SidewaysTreeReader.tree(fromLines: drawing(tree))
        #expect(firstDifference(rebuilt?.levelOrder ?? [], tree?.levelOrder ?? []) == nil)
    }
}
