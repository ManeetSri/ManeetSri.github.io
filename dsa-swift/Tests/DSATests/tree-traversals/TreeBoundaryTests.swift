import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The boundary worked out in one recursive pass, a different method from the solution: each node
/// knows whether it's on the left edge or the right edge, and passes that on to the right children.
private func referenceBoundary(_ root: TreeNode?) -> [Int] {
    guard let root else { return [] }
    if root.left == nil && root.right == nil { return [root.value] }
    var leftEdge: [Int] = []
    var leaves: [Int] = []
    var rightEdge: [Int] = []
    func walk(_ node: TreeNode?, onLeftEdge: Bool, onRightEdge: Bool) {
        guard let node else { return }
        if node.left == nil && node.right == nil {
            leaves.append(node.value)
        } else if onLeftEdge {
            leftEdge.append(node.value)
        } else if onRightEdge {
            rightEdge.append(node.value)
        }
        // The left edge always continues left, and only goes right when there's no left child
        walk(node.left, onLeftEdge: onLeftEdge, onRightEdge: onRightEdge && node.right == nil)
        walk(node.right, onLeftEdge: onLeftEdge && node.left == nil, onRightEdge: onRightEdge)
    }
    walk(root.left, onLeftEdge: true, onRightEdge: false)
    walk(root.right, onLeftEdge: false, onRightEdge: true)
    return [root.value] + leftEdge + leaves + rightEdge.reversed()
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

@Suite struct TreeBoundaryTests {
    @Test("Small trees", arguments: [
        ([1, 2, 3, 4, 5, nil, 6, nil, nil, 7], [1, 2, 4, 7, 6, 3]),
        ([1, 2, 3, 4, 5, 6, 7], [1, 2, 4, 5, 6, 7, 3]),
        ([1, nil, 2, 3, 4], [1, 3, 4, 2]),
        ([1, 2, nil, 3, nil, 4], [1, 2, 3, 4]),
        ([1, nil, 2, nil, 3, nil, 4], [1, 4, 3, 2]),
        ([1, 2, 3, nil, 4, nil, nil, 5, 6], [1, 2, 4, 5, 6, 3]),
        ([1, 2, 3, 4, nil, 5, nil, nil, nil, 6, 7], [1, 2, 4, 6, 7, 5, 3]),
        ([1, 2], [1, 2]),
        ([1, nil, 2], [1, 2]),
        ([5], [5]),
        ([0, -1, -1, -2, nil, nil, -2], [0, -1, -2, -2, -1]),
    ] as [([Int?], [Int])])
    func small(levelOrder: [Int?], expected: [Int]) {
        #expect(TreeBoundary.boundary(TreeNode.make(levelOrder)) == expected)
    }

    @Test("The empty tree")
    func empty() {
        #expect(TreeBoundary.boundary(nil) == [])
    }

    @Test("A leaf deep inside the tree is listed with the leaves, not as part of an edge")
    func innerLeaves() {
        // 1 → 2 (left edge) → its right child 4 continues the edge; 3's subtree has inner leaves
        let root = TreeNode.make([1, 2, 3, nil, 4, 5, 6, 7, nil, nil, 8, 9])
        #expect(TreeBoundary.boundary(root) == [1, 2, 4, 7, 8, 9, 6, 3])
    }

    @Test("Chains 500 levels deep")
    func chains() {
        let left = TreeNode(1)
        var current = left
        for value in 2...500 {
            let next = TreeNode(value)
            current.left = next
            current = next
        }
        #expect(firstDifference(TreeBoundary.boundary(left), Array(1...500)) == nil)
        let right = TreeNode(1)
        current = right
        for value in 2...500 {
            let next = TreeNode(value)
            current.right = next
            current = next
        }
        #expect(firstDifference(TreeBoundary.boundary(right), [1, 500] + Array((2...499).reversed())) == nil)
    }

    @Test("A complete tree of 100,000 nodes")
    func largeComplete() {
        // Values 1...n in level order: node i has children 2i and 2i + 1, and it's a leaf when 2i > n.
        // The left edge is the powers of two, the right edge one less than powers of two. The last level
        // holds 65,536...100,000; the leaves on the level above, 50,001...65,535, come after them.
        let n = 100_000
        let leftEdge = (1...15).map { 1 << $0 }
        let leaves = Array(65_536...n) + Array(50_001...65_535)
        let rightEdge = (2...15).map { (1 << $0) - 1 }.reversed()
        let expected = [1] + leftEdge + leaves + rightEdge
        #expect(firstDifference(TreeBoundary.boundary(TreeNode.make(Array(1...n))), expected) == nil)
    }

    @Test("A bushy tree of 100,000 nodes with gaps")
    func largeBushy() {
        var levelOrder: [Int?] = [0]
        var nodes = 1
        var index = 1
        while nodes < 100_000 {
            if index % 3 == 1 || index % 17 == 4 {
                levelOrder.append(nil)
            } else {
                levelOrder.append(index)
                nodes += 1
            }
            index += 1
        }
        let root = TreeNode.make(levelOrder)
        #expect(firstDifference(TreeBoundary.boundary(root), referenceBoundary(root)) == nil)
    }
}
