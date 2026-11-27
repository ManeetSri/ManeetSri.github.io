import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Node = RedBlackAudit.Node

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

/// The answer worked out straight from the definition: the inorder values must increase, no red may
/// have a red parent, and every root-to-nil path must count the same number of black nodes.
private func referenceBlackHeight(_ root: Node?) -> Int? {
    guard let root else { return 0 }
    if root.isRed { return nil }
    var values: [Int] = []
    var pathCounts = Set<Int>()
    var redRed = false
    func walk(_ node: Node?, _ blacksAbove: Int, _ parentRed: Bool) {
        guard let node else { pathCounts.insert(blacksAbove); return }
        if node.isRed && parentRed { redRed = true }
        let blacks = blacksAbove + (node.isRed ? 0 : 1)
        walk(node.left, blacks, node.isRed)
        values.append(node.value)
        walk(node.right, blacks, node.isRed)
    }
    walk(root, 0, false)
    let increasing = zip(values, values.dropFirst()).allSatisfy { $0 < $1 }
    return increasing && !redRed && pathCounts.count == 1 ? pathCounts.first : nil
}

/// A 2-3-4 tree node, used to make random valid red-black trees.
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

/// A random valid red-black tree of up to `count` distinct keys, and its black-height.
private func randomValidTree(count: Int, dice: inout Dice) -> (root: Node?, blackHeight: Int) {
    var root234: Node234? = nil
    for _ in 0..<count {
        root234 = insert234(dice.roll(10 * count + 10) - 5 * count, into: root234)
    }
    var levels = 0
    var probe = root234
    while let node = probe {
        levels += 1
        probe = node.children.first
    }
    var leanDice = Dice(state: dice.state)
    return (encode(root234) { _ in leanDice.roll(2) == 0 }, levels)
}

/// Every node in preorder, with a loop.
private func allNodes(_ root: Node?) -> [Node] {
    var result: [Node] = []
    var stack = [root].compactMap { $0 }
    while let node = stack.popLast() {
        result.append(node)
        if let right = node.right { stack.append(right) }
        if let left = node.left { stack.append(left) }
    }
    return result
}

@Suite struct RedBlackAuditTests {
    @Test("The lesson's tree has black-height 3")
    func lessonTree() {
        let root = tree(["4B", "2B", "6B", "1B", "3B", "5B", "8R", nil, nil, nil, nil, nil, nil, "7B", "9B", nil, nil, nil, "10R"])
        #expect(RedBlackAudit.blackHeight(of: root) == 3)
    }

    @Test("The other examples", arguments: [
        (["2B", "1R", "3R"], 1 as Int?),
        (["2R", "1B", "3B"], nil),
        (["3B", "2R", nil, "1R"], nil),
        (["2B", "1B"], nil),
        (["5B", "3R", "8R", "1B", "6B", "7B", "9B"], nil),
        ([], 0),
    ] as [([String?], Int?)])
    func examples(levelOrder: [String?], expected: Int?) {
        #expect(RedBlackAudit.blackHeight(of: tree(levelOrder)) == expected)
    }

    @Test("More hand-checked trees", arguments: [
        (["7B"], 1 as Int?),
        (["7R"], nil),                                            // a lone red root
        (["2B", "1R"], 1),                                        // a 3-node leaning left
        (["1B", nil, "2R"], 1),                                   // and leaning right
        (["2B", "2R"], nil),                                      // a duplicate value
        (["2B", "1R", "1R"], nil),                                // out of order: 1 on the right of 2
        (["10B", "5B", "15B", "3R", "7R"], 2),
        (["10B", "5R", "15B", "3B", "7B"], 2),                    // the 3-node [5 10] over three 2-nodes
        (["10B", "5B", "15B", "3B"], nil),                        // the path through 3 has an extra black
        (["10B", "5R", "15R", "3B", "12B", "13B", "20B"], nil),   // 12 is in 10's left subtree
        (["10B", "5B", "15B", nil, nil, "12R", "20R", "11R"], nil),  // 12 and 11 are two reds in a row
    ] as [([String?], Int?)])
    func handChecked(levelOrder: [String?], expected: Int?) {
        #expect(RedBlackAudit.blackHeight(of: tree(levelOrder)) == expected)
    }

    @Test("Int.min and Int.max are legal values")
    func extremes() {
        #expect(RedBlackAudit.blackHeight(of: Node(0, left: Node(Int.min, red: true), right: Node(Int.max, red: true))) == 1)
        #expect(RedBlackAudit.blackHeight(of: Node(Int.min, right: Node(Int.max, red: true))) == 1)
        #expect(RedBlackAudit.blackHeight(of: Node(Int.max, right: Node(Int.max, red: true))) == nil)
    }

    @Test("Random valid trees report the 2-3-4 height")
    func validTrees() {
        var dice = Dice(state: 38)
        var failures: [String] = []
        for count in 1...200 {
            let (root, expected) = randomValidTree(count: count, dice: &dice)
            let actual = RedBlackAudit.blackHeight(of: root)
            if actual != expected && failures.count < 3 {
                failures.append("\(count) keys: got \(String(describing: actual)), expected \(expected)")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Random damage: one colour flipped, or two values swapped")
    func damagedTrees() {
        var dice = Dice(state: 380)
        var failures: [String] = []
        for count in 2...150 {
            let (root, _) = randomValidTree(count: count, dice: &dice)
            let nodes = allNodes(root)
            // Flip one colour: sometimes still valid (a red leaf turning black is not), compare with the reference
            let flipped = nodes[dice.roll(nodes.count)]
            flipped.isRed.toggle()
            let expected = referenceBlackHeight(root)
            let actual = RedBlackAudit.blackHeight(of: root)
            if actual != expected && failures.count < 3 {
                failures.append("flipped \(flipped.value) in a tree of \(count): got \(String(describing: actual)), expected \(String(describing: expected))")
            }
            flipped.isRed.toggle()
            // Swap two different values: the inorder is no longer increasing
            let a = nodes[dice.roll(nodes.count)]
            let b = nodes[dice.roll(nodes.count)]
            guard a !== b else { continue }
            (a.value, b.value) = (b.value, a.value)
            if RedBlackAudit.blackHeight(of: root) != nil && failures.count < 3 {
                failures.append("swapped \(a.value) and \(b.value) in a tree of \(count), but it was accepted")
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("A valid tree of 100,000 keys, then the same tree damaged deep down")
    func large() {
        var root234: Node234? = nil
        for key in 0..<100_000 {
            root234 = insert234((key * 7_919) % 100_000, into: root234)
        }
        var levels = 0
        var probe = root234
        while let node = probe {
            levels += 1
            probe = node.children.first
        }
        var dice = Dice(state: 3_800)
        let root = encode(root234) { _ in dice.roll(2) == 0 }
        #expect(RedBlackAudit.blackHeight(of: root) == levels)
        // The leftmost node is a leaf whose value is the smallest; give it a value too large for its place
        var leftmost = root!
        while let next = leftmost.left { leftmost = next }
        leftmost.value = 50_000
        #expect(RedBlackAudit.blackHeight(of: root) == nil)
    }
}
