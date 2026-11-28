import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// All three orders worked out a different way from the solutions: a stack of (node, ready) pairs.
/// Expanding a node pushes its children and the node itself, marked ready, in the order the traversal
/// wants them; a ready node is written out when it comes off the stack.
private func referenceOrders(_ root: TreeNode?) -> (pre: [Int], inOrder: [Int], post: [Int]) {
    func walk(nodeAt position: Int) -> [Int] {        // 0 before, 1 between, 2 after the children
        var result: [Int] = []
        var stack: [(TreeNode, Bool)] = root.map { [($0, false)] } ?? []
        while let (node, ready) = stack.popLast() {
            if ready {
                result.append(node.value)
                continue
            }
            var steps: [(TreeNode, Bool)] = []
            if position == 0 { steps.append((node, true)) }
            if let left = node.left { steps.append((left, false)) }
            if position == 1 { steps.append((node, true)) }
            if let right = node.right { steps.append((right, false)) }
            if position == 2 { steps.append((node, true)) }
            stack.append(contentsOf: steps.reversed())      // so the first step comes off first
        }
        return result
    }
    return (walk(nodeAt: 0), walk(nodeAt: 1), walk(nodeAt: 2))
}

/// A binary search tree of `count` pseudo-random values (the same every run), inserted with a loop.
private func randomTree(count: Int, seed: UInt64) -> TreeNode? {
    var state = seed
    var root: TreeNode? = nil
    for _ in 0..<count {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        let value = Int(state >> 33) % 1_000_000
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

/// A chain of `count` nodes holding 1...count from the top. `goesLeft(i)` says whether node i + 1 hangs
/// to the left of node i. Built with a loop, so any depth is fine.
private func chain(_ count: Int, goesLeft: (Int) -> Bool) -> TreeNode {
    let root = TreeNode(1)
    var current = root
    for value in 2...count {
        let next = TreeNode(value)
        if goesLeft(value - 1) { current.left = next } else { current.right = next }
        current = next
    }
    return root
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

@Suite struct StackTraversalsTests {
    @Test("The running example")
    func runningExample() {
        let root = TreeNode.make([1, 2, 3, 4, 5, nil, 6, nil, nil, 7])
        #expect(StackTraversals.preorder(root) == [1, 2, 4, 5, 7, 3, 6])
        #expect(StackTraversals.inorder(root) == [4, 2, 7, 5, 1, 3, 6])
        #expect(StackTraversals.postorder(root) == [4, 7, 5, 2, 6, 3, 1])
    }

    @Test("A binary search tree: inorder is sorted")
    func searchTree() {
        let root = TreeNode.make([8, 3, 10, 1, 6, nil, 14, nil, nil, 4, 7, 13])
        #expect(StackTraversals.preorder(root) == [8, 3, 1, 6, 4, 7, 10, 14, 13])
        #expect(StackTraversals.inorder(root) == [1, 3, 4, 6, 7, 8, 10, 13, 14])
        #expect(StackTraversals.postorder(root) == [1, 4, 7, 6, 3, 13, 14, 10, 8])
    }

    @Test("Empty and single-node trees")
    func tiny() {
        #expect(StackTraversals.preorder(nil) == [])
        #expect(StackTraversals.inorder(nil) == [])
        #expect(StackTraversals.postorder(nil) == [])
        let single = TreeNode(-4)
        #expect(StackTraversals.preorder(single) == [-4])
        #expect(StackTraversals.inorder(single) == [-4])
        #expect(StackTraversals.postorder(single) == [-4])
    }

    @Test("Every small shape matches the reference", arguments: [
        [1, 2], [1, nil, 2], [1, 2, 3], [1, 2, nil, 3], [1, nil, 2, 3], [1, 2, nil, nil, 3],
        [1, nil, 2, nil, 3], [1, 2, 3, 4, 5, 6, 7], [1, 2, 3, nil, 4, 5], [5, 3, 3, 3, nil, nil, 3],
        [0, -1, -1, 2, nil, nil, 2], [1, 2, 3, 4, nil, nil, 5, 6, nil, nil, 7, 8, nil, nil, 9],
    ] as [[Int?]])
    func shapes(levelOrder: [Int?]) {
        let root = TreeNode.make(levelOrder)
        let expected = referenceOrders(root)
        #expect(StackTraversals.preorder(root) == expected.pre)
        #expect(StackTraversals.inorder(root) == expected.inOrder)
        #expect(StackTraversals.postorder(root) == expected.post)
    }

    @Test("Nodes are visited, not changed: the tree is the same afterwards")
    func unchanged() {
        let levelOrder: [Int?] = [1, 2, 3, 4, 5, nil, 6, nil, nil, 7]
        let root = TreeNode.make(levelOrder)
        _ = StackTraversals.preorder(root)
        _ = StackTraversals.inorder(root)
        _ = StackTraversals.postorder(root)
        #expect(root?.levelOrder == levelOrder)
    }

    @Test("A chain 100,000 nodes deep, leaning left")
    func deepLeft() {
        let n = 100_000
        let root = chain(n) { _ in true }
        #expect(firstDifference(StackTraversals.preorder(root), Array(1...n)) == nil)
        #expect(firstDifference(StackTraversals.inorder(root), Array((1...n).reversed())) == nil)
        #expect(firstDifference(StackTraversals.postorder(root), Array((1...n).reversed())) == nil)
    }

    @Test("A chain 100,000 nodes deep, leaning right")
    func deepRight() {
        let n = 100_000
        let root = chain(n) { _ in false }
        #expect(firstDifference(StackTraversals.preorder(root), Array(1...n)) == nil)
        #expect(firstDifference(StackTraversals.inorder(root), Array(1...n)) == nil)
        #expect(firstDifference(StackTraversals.postorder(root), Array((1...n).reversed())) == nil)
    }

    @Test("A zigzag chain 100,000 nodes deep")
    func deepZigzag() {
        let n = 100_000
        let root = chain(n) { $0 % 3 != 0 }
        let expected = referenceOrders(root)
        #expect(firstDifference(StackTraversals.preorder(root), expected.pre) == nil)
        #expect(firstDifference(StackTraversals.inorder(root), expected.inOrder) == nil)
        #expect(firstDifference(StackTraversals.postorder(root), expected.post) == nil)
    }

    @Test("A random tree of 100,000 nodes")
    func largeRandom() {
        let root = randomTree(count: 100_000, seed: 35)
        let expected = referenceOrders(root)
        #expect(firstDifference(StackTraversals.preorder(root), expected.pre) == nil)
        #expect(firstDifference(StackTraversals.inorder(root), expected.inOrder) == nil)
        #expect(firstDifference(StackTraversals.postorder(root), expected.post) == nil)
    }
}
