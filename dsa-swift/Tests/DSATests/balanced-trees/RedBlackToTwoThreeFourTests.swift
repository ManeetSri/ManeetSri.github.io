import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Node = RedBlackToTwoThreeFour.Node

/// Builds a tree from its level order, written like "4B" or "8R", with nil for a missing child of a
/// node that exists (the same layout as TreeNode.make).
private func tree(_ levelOrder: [String?]) -> Node? {
    func node(_ text: String) -> Node {
        Node(Int(text.dropLast())!, red: text.hasSuffix("R"))
    }
    guard let first = levelOrder.first, let rootText = first else { return nil }
    let root = node(rootText)
    var parents = [root]
    var head = 0
    var index = 1
    while index < levelOrder.count && head < parents.count {
        let parent = parents[head]
        head += 1
        if let text = levelOrder[index] {
            parent.left = node(text)
            parents.append(parent.left!)
        }
        index += 1
        if index < levelOrder.count, let text = levelOrder[index] {
            parent.right = node(text)
            parents.append(parent.right!)
        }
        index += 1
    }
    return root
}

/// A 2-3-4 tree node: the tests build these, encode them as red-black trees, and expect them back.
private final class Node234 {
    var keys: [Int]
    var children: [Node234]
    init(_ keys: [Int], _ children: [Node234] = []) {
        self.keys = keys
        self.children = children
    }
}

/// Inserts `key` with top-down splitting, returning the (possibly new) root.
private func insert234(_ key: Int, into root: Node234?) -> Node234 {
    func split(_ parent: Node234, _ i: Int) {
        let full = parent.children[i]
        let left = Node234([full.keys[0]], Array(full.children.prefix(2)))
        let right = Node234([full.keys[2]], Array(full.children.dropFirst(2)))
        parent.keys.insert(full.keys[1], at: i)
        parent.children[i] = left
        parent.children.insert(right, at: i + 1)
    }
    guard var root else { return Node234([key]) }
    if root.keys.count == 3 {
        let newRoot = Node234([], [root])
        split(newRoot, 0)
        root = newRoot
    }
    var node = root
    while true {
        var i = 0
        while i < node.keys.count && node.keys[i] < key { i += 1 }
        if i < node.keys.count && node.keys[i] == key { return root }
        if node.children.isEmpty {
            node.keys.insert(key, at: i)
            return root
        }
        if node.children[i].keys.count == 3 {
            split(node, i)
            if key == node.keys[i] { return root }
            if key > node.keys[i] { i += 1 }
        }
        node = node.children[i]
    }
}

/// The 2-3-4 tree's levels, in the form the solution returns.
private func levels234(_ root: Node234?) -> [[[Int]]] {
    var result: [[[Int]]] = []
    var level = [root].compactMap { $0 }
    while !level.isEmpty {
        result.append(level.map(\.keys))
        level = level.flatMap(\.children)
    }
    return result
}

/// The red-black encoding of a 2-3-4 tree; `leanRight(node)` picks which way each 3-node leans.
private func encode(_ node: Node234?, leanRight: (Node234) -> Bool) -> Node? {
    guard let node else { return nil }
    let kids = node.children.map { encode($0, leanRight: leanRight) }
    let child = { (i: Int) in i < kids.count ? kids[i] : nil }
    switch node.keys.count {
    case 1:
        return Node(node.keys[0], left: child(0), right: child(1))
    case 2:
        if leanRight(node) {
            return Node(node.keys[0], left: child(0), right: Node(node.keys[1], red: true, left: child(1), right: child(2)))
        }
        return Node(node.keys[1], left: Node(node.keys[0], red: true, left: child(0), right: child(1)), right: child(2))
    default:
        return Node(node.keys[1],
                    left: Node(node.keys[0], red: true, left: child(0), right: child(1)),
                    right: Node(node.keys[2], red: true, left: child(2), right: child(3)))
    }
}

private struct Dice {
    var state: UInt64
    mutating func roll(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int(state >> 33) % bound
    }
}

@Suite struct RedBlackToTwoThreeFourTests {
    @Test("The lesson's two trees")
    func lessonTrees() {
        let first = tree(["40B", "20R", "60B", "10B", "30B", "50R", "70R", "5R", "15R", "25R"])
        #expect(RedBlackToTwoThreeFour.levels(of: first) == [[[20, 40]], [[5, 10, 15], [25, 30], [50, 60, 70]]])
        let second = tree(["4B", "2B", "6B", "1B", "3B", "5B", "8R", nil, nil, nil, nil, nil, nil, "7B", "9B", nil, nil, nil, "10R"])
        #expect(RedBlackToTwoThreeFour.levels(of: second) == [[[4]], [[2], [6, 8]], [[1], [3], [5], [7], [9, 10]]])
    }

    @Test("Small trees", arguments: [
        (["2B", "1R", "3R"], [[[1, 2, 3]]]),
        (["1B", nil, "2R"], [[[1, 2]]]),
        (["2B", "1R"], [[[1, 2]]]),
        (["7B"], [[[7]]]),
        (["2B", "1B", "3B"], [[[2]], [[1], [3]]]),
        (["4B", "2R", "6B", "1B", "3B", "5R", "7R"], [[[2, 4]], [[1], [3], [5, 6, 7]]]),
        (["-1B", "-5B", "8B", "-9R", nil, "3R", "12R"], [[[-1]], [[-9, -5], [3, 8, 12]]]),
    ] as [([String?], [[[Int]]])])
    func small(levelOrder: [String?], expected: [[[Int]]]) {
        #expect(RedBlackToTwoThreeFour.levels(of: tree(levelOrder)) == expected)
    }

    @Test("The empty tree has no levels")
    func empty() {
        #expect(RedBlackToTwoThreeFour.levels(of: nil) == [])
    }

    @Test("Hundreds of random 2-3-4 trees, with 3-nodes leaning both ways, come back")
    func manyRandom() {
        var dice = Dice(state: 39)
        var failures: [String] = []
        for count in 1...250 {
            var root234: Node234? = nil
            for _ in 0..<count {
                root234 = insert234(dice.roll(4 * count) - 2 * count, into: root234)
            }
            let expected = levels234(root234)
            let actual = RedBlackToTwoThreeFour.levels(of: encode(root234) { _ in dice.roll(2) == 0 })
            if actual != expected && failures.count < 3 {
                failures.append("got \(actual), expected \(expected)")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("The tree is read, not changed")
    func unchanged() {
        let root = tree(["4B", "2R", "6B", "1B", "3B", "5R", "7R"])
        _ = RedBlackToTwoThreeFour.levels(of: root)
        #expect(root?.left?.isRed == true && root?.left?.value == 2)
        #expect(root?.right?.left?.isRed == true && root?.right?.right?.value == 7)
        #expect(RedBlackToTwoThreeFour.levels(of: root) == [[[2, 4]], [[1], [3], [5, 6, 7]]])
    }

    @Test("A tree of 100,000 keys")
    func large() {
        var root234: Node234? = nil
        for key in 0..<100_000 {
            root234 = insert234((key * 7_919) % 100_000, into: root234)
        }
        var dice = Dice(state: 390)
        let root = encode(root234) { _ in dice.roll(2) == 0 }
        let actual = RedBlackToTwoThreeFour.levels(of: root)
        let expected = levels234(root234)
        #expect(actual.count == expected.count)
        #expect(actual == expected)
    }
}
