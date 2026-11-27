import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small random number generator that gives the same numbers every run.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

/// A tree of `count` nodes in a random shape, holding 0 to count − 1.
private func randomTree(_ count: Int, generator: inout SeededGenerator) -> TreeNode? {
    guard count > 0 else { return nil }
    let root = TreeNode(0)
    for value in 1..<count {
        var node = root
        while true {
            if Bool.random(using: &generator) {
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

/// Every node, in level order.
private func nodes(of root: TreeNode?) -> [TreeNode] {
    var order: [TreeNode] = root.map { [$0] } ?? []
    var head = 0
    while head < order.count {
        let node = order[head]
        head += 1
        if let left = node.left { order.append(left) }
        if let right = node.right { order.append(right) }
    }
    return order
}

/// Distances from depths and parents: climb from the deeper node until the two meet.
private func distance(_ a: TreeNode, _ b: TreeNode, parent: [ObjectIdentifier: TreeNode], depth: [ObjectIdentifier: Int]) -> Int {
    var a = a
    var b = b
    var steps = 0
    while a !== b {
        if depth[ObjectIdentifier(a)]! >= depth[ObjectIdentifier(b)]! {
            a = parent[ObjectIdentifier(a)]!
        } else {
            b = parent[ObjectIdentifier(b)]!
        }
        steps += 1
    }
    return steps
}

/// The width worked out by listing, for each level, the positions of its nodes as exact numbers of
/// "left/right turns". Only for trees under 60 levels, where positions fit in an Int.
private func referenceWidth(_ root: TreeNode?) -> Int {
    var level: [(TreeNode, Int)] = root.map { [($0, 0)] } ?? []
    var widest = 0
    while let first = level.first, let last = level.last {
        widest = max(widest, last.1 - first.1 + 1)
        level = level.flatMap { node, position in
            [(node.left, 2 * position), (node.right, 2 * position + 1)].compactMap { child, place in child.map { ($0, place) } }
        }
    }
    return widest
}

/// A chain of `count` nodes: each one is the left child of the one above if `turns(depth)` is true,
/// otherwise the right child. Returns the top and the bottom.
private func chain(_ count: Int, turnsLeft: (Int) -> Bool) -> (top: TreeNode, bottom: TreeNode) {
    let top = TreeNode(0)
    var bottom = top
    for depth in 1..<count {
        let node = TreeNode(depth)
        if turnsLeft(depth) { bottom.left = node } else { bottom.right = node }
        bottom = node
    }
    return (top, bottom)
}

@Suite struct DistanceKAndWidthTests {
    static let example: [Int?] = [7, 3, 9, 1, 5, nil, 12, nil, nil, 4, 6]

    // MARK: values(atDistance:from:in:)

    @Test("Distances in the example", arguments: [
        (5, 0, [5]), (5, 1, [3, 4, 6]), (5, 2, [1, 7]), (5, 3, [9]), (5, 4, [12]), (5, 5, []),
        (4, 4, [9]), (4, 5, [12]), (4, 6, []), (7, 2, [1, 5, 12]), (12, 3, [3]), (12, 4, [1, 5]),
    ] as [(Int, Int, [Int])])
    func examples(target: Int, distance: Int, expected: [Int]) throws {
        let tree = try #require(TreeNode.make(Self.example))
        let start = try #require(tree.find(target))
        #expect(DistanceKAndWidth.values(atDistance: distance, from: start, in: tree) == expected)
    }

    @Test("Every target and every distance in 60 random trees")
    func randomDistances() {
        var generator = SeededGenerator(state: 40)
        var firstMismatch: String? = nil
        for round in 1...60 {
            let tree = randomTree(round % 30 + 1, generator: &generator)
            let all = nodes(of: tree)
            var parent: [ObjectIdentifier: TreeNode] = [:]
            var depth: [ObjectIdentifier: Int] = [ObjectIdentifier(all[0]): 0]
            for node in all {
                for child in [node.left, node.right].compactMap({ $0 }) {
                    parent[ObjectIdentifier(child)] = node
                    depth[ObjectIdentifier(child)] = depth[ObjectIdentifier(node)]! + 1
                }
            }
            for target in all {
                for k in 0...12 {
                    let expected = all.filter { distance(target, $0, parent: parent, depth: depth) == k }.map(\.value).sorted()
                    if DistanceKAndWidth.values(atDistance: k, from: target, in: tree) != expected {
                        firstMismatch = firstMismatch ?? "distance \(k) from \(target.value) in \(tree!.description)"
                    }
                }
            }
        }
        #expect(firstMismatch == nil, "the first case with a wrong answer")
    }

    @Test("A perfect tree of 131,071 nodes")
    func largeDistances() {
        // Values are level-order positions from 1, so the parent of v is v / 2
        let tree = TreeNode.make(Array(1...131_071))
        let byValue = [nil] + nodes(of: tree).map { Optional($0) }
        func heapDistance(_ a: Int, _ b: Int) -> Int {
            var a = a, b = b, steps = 0
            while a != b {
                if a > b { a /= 2 } else { b /= 2 }
                steps += 1
            }
            return steps
        }
        for (target, k) in [(1, 16), (70_000, 3), (70_000, 20), (5, 7), (131_071, 32)] {
            let expected = (1...131_071).filter { heapDistance(target, $0) == k }
            let matches = DistanceKAndWidth.values(atDistance: k, from: byValue[target]!, in: tree) == expected
            #expect(matches, "distance \(k) from \(target) should give \(expected.count) values")
        }
    }

    // MARK: maximumWidth

    @Test("Widths of the examples", arguments: [
        ([7, 3, 9, 1, 5, nil, 12, nil, nil, 4, 6], 4),
        ([1, 2, 3, 4, nil, nil, 5], 4),
        ([1, 2, nil, 3], 1),
        ([1, 2, 3], 2),
        ([1], 1),
        ([1, 2, 3, nil, 4, 5], 2),
        ([1, 2, 3, 4, nil, nil, 5, 6, nil, nil, 7], 8),
    ] as [([Int?], Int)])
    func widths(levelOrder: [Int?], expected: Int) {
        #expect(DistanceKAndWidth.maximumWidth(TreeNode.make(levelOrder)) == expected)
    }

    @Test("The empty tree has width 0")
    func emptyWidth() {
        #expect(DistanceKAndWidth.maximumWidth(nil) == 0)
    }

    @Test("Matches a direct count on 300 random trees")
    func randomWidths() {
        var generator = SeededGenerator(state: 41)
        var firstMismatch: String? = nil
        for round in 0..<300 {
            let tree = randomTree(round % 40, generator: &generator)
            if DistanceKAndWidth.maximumWidth(tree) != referenceWidth(tree) {
                firstMismatch = firstMismatch ?? (tree?.description ?? "[]")
            }
        }
        #expect(firstMismatch == nil, "the first tree with a wrong answer")
    }

    @Test("Large trees: 131,071 perfect and 150,000 random")
    func largeWidths() {
        let perfect = TreeNode.make(Array(1...131_071))
        #expect(DistanceKAndWidth.maximumWidth(perfect) == 65_536)
        var generator = SeededGenerator(state: 42)
        let tree = randomTree(150_000, generator: &generator)
        #expect(DistanceKAndWidth.maximumWidth(tree) == referenceWidth(tree))
    }

    @Test("Two chains 30 levels down from the root: the bottom level spans 2^30 places")
    func wideApart() {
        let root = TreeNode(0)
        root.left = chain(30, turnsLeft: { _ in true }).top
        root.right = chain(30, turnsLeft: { _ in false }).top
        #expect(DistanceKAndWidth.maximumWidth(root) == 1 << 30)
    }

    @Test("A chain 300 levels deep: positions counted from the root overflow, so measure each level from its first node")
    func deepChains() {
        // Straight down the left, then a perfect tree of 4 levels at the bottom: width 8
        let straight = chain(300, turnsLeft: { _ in true })
        straight.bottom.left = TreeNode.make(Array(1...15))
        #expect(DistanceKAndWidth.maximumWidth(straight.top) == 8)
        // Zigzagging, then two children at the bottom: width 2
        let zigzag = chain(300, turnsLeft: { $0 % 2 == 0 })
        zigzag.bottom.left = TreeNode(-1)
        zigzag.bottom.right = TreeNode(-2)
        #expect(DistanceKAndWidth.maximumWidth(zigzag.top) == 2)
    }
}
