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

@Suite struct TraversalOrdersTests {
    @Test("The running example")
    func runningExample() {
        let root = TreeNode.make([1, 2, 3, 4, 5, nil, 6, nil, nil, 7])
        #expect(TraversalOrders.preorder(root) == [1, 2, 4, 5, 7, 3, 6])
        #expect(TraversalOrders.inorder(root) == [4, 2, 7, 5, 1, 3, 6])
        #expect(TraversalOrders.postorder(root) == [4, 7, 5, 2, 6, 3, 1])
    }

    @Test("A binary search tree: inorder is sorted")
    func searchTree() {
        let root = TreeNode.make([8, 3, 10, 1, 6, nil, 14, nil, nil, 4, 7, 13])
        #expect(TraversalOrders.preorder(root) == [8, 3, 1, 6, 4, 7, 10, 14, 13])
        #expect(TraversalOrders.inorder(root) == [1, 3, 4, 6, 7, 8, 10, 13, 14])
        #expect(TraversalOrders.postorder(root) == [1, 4, 7, 6, 3, 13, 14, 10, 8])
    }

    @Test("Empty, single node and short chains")
    func small() {
        #expect(TraversalOrders.preorder(nil) == [])
        #expect(TraversalOrders.inorder(nil) == [])
        #expect(TraversalOrders.postorder(nil) == [])
        let single = TreeNode(5)
        #expect(TraversalOrders.preorder(single) == [5])
        #expect(TraversalOrders.inorder(single) == [5])
        #expect(TraversalOrders.postorder(single) == [5])
        let leftChain = TreeNode.make([3, 2, nil, 1])
        #expect(TraversalOrders.preorder(leftChain) == [3, 2, 1])
        #expect(TraversalOrders.inorder(leftChain) == [1, 2, 3])
        #expect(TraversalOrders.postorder(leftChain) == [1, 2, 3])
        let rightChain = TreeNode.make([1, nil, 2, nil, 3])
        #expect(TraversalOrders.preorder(rightChain) == [1, 2, 3])
        #expect(TraversalOrders.inorder(rightChain) == [1, 2, 3])
        #expect(TraversalOrders.postorder(rightChain) == [3, 2, 1])
    }

    @Test("Duplicates and negative values keep their positions")
    func duplicates() {
        let root = TreeNode.make([0, -1, -1, 2, nil, nil, 2])
        #expect(TraversalOrders.preorder(root) == [0, -1, 2, -1, 2])
        #expect(TraversalOrders.inorder(root) == [2, -1, 0, -1, 2])
        #expect(TraversalOrders.postorder(root) == [2, -1, 2, -1, 0])
    }

    @Test("A perfect tree of 131,071 nodes")
    func largePerfect() {
        let root = TreeNode.make(Array(1...131_071))
        let expected = referenceOrders(root)
        #expect(firstDifference(TraversalOrders.preorder(root), expected.pre) == nil)
        #expect(firstDifference(TraversalOrders.inorder(root), expected.inOrder) == nil)
        #expect(firstDifference(TraversalOrders.postorder(root), expected.post) == nil)
        #expect(expected.pre.prefix(4) == [1, 2, 4, 8])
    }

    @Test("A random tree of 100,000 nodes")
    func largeRandom() {
        let root = randomTree(count: 100_000, seed: 34)
        let expected = referenceOrders(root)
        #expect(firstDifference(TraversalOrders.preorder(root), expected.pre) == nil)
        #expect(firstDifference(TraversalOrders.inorder(root), expected.inOrder) == nil)
        #expect(firstDifference(TraversalOrders.postorder(root), expected.post) == nil)
        #expect(expected.inOrder == expected.inOrder.sorted())
    }

    @Test("A zigzag chain 500 levels deep")
    func chain() {
        let root = TreeNode(0)
        var current = root
        for value in 1..<500 {
            let next = TreeNode(value)
            if value % 2 == 0 { current.left = next } else { current.right = next }
            current = next
        }
        let expected = referenceOrders(root)
        #expect(firstDifference(TraversalOrders.preorder(root), Array(0..<500)) == nil)
        #expect(firstDifference(TraversalOrders.inorder(root), expected.inOrder) == nil)
        #expect(firstDifference(TraversalOrders.postorder(root), Array((0..<500).reversed())) == nil)
    }
}
