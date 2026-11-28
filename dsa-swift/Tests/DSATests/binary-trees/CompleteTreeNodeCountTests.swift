import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A complete tree with `size` nodes, built cheaply. Complete trees of the same size have the same shape,
/// so equal-sized subtrees are shared instead of copied: a tree of 400 million nodes takes about 60
/// objects. That's invisible to code that only reads the tree.
private func sharedCompleteTree(_ size: Int, cache: inout [Int: TreeNode]) -> TreeNode? {
    guard size > 0 else { return nil }
    if let known = cache[size] { return known }
    let levels = Int.bitWidth - size.leadingZeroBitCount     // full levels, plus a partial one if any
    var leftSize = 0
    if levels >= 2 {
        let onLastLevel = size - ((1 << (levels - 1)) - 1)
        let leftCapacity = 1 << (levels - 2)                  // last-level places under the left child
        leftSize = (leftCapacity - 1) + min(onLastLevel, leftCapacity)
    }
    let left = sharedCompleteTree(leftSize, cache: &cache)
    let right = sharedCompleteTree(size - 1 - leftSize, cache: &cache)
    let node = TreeNode(0, left: left, right: right)
    cache[size] = node
    return node
}

@Suite struct CompleteTreeNodeCountTests {
    @Test("The examples", arguments: [
        ([1, 2, 3, 4, 5, 6], 6),
        ([1, 2, 3, 4, 5, 6, 7], 7),
        ([1, 2, 3, 4], 4),
        ([1], 1),
    ] as [([Int?], Int)])
    func examples(levelOrder: [Int?], expected: Int) {
        #expect(CompleteTreeNodeCount.count(TreeNode.make(levelOrder)) == expected)
    }

    @Test("The empty tree has no nodes")
    func empty() {
        #expect(CompleteTreeNodeCount.count(nil) == 0)
    }

    @Test("Every size from 1 to 600")
    func everySize() {
        var wrong: [Int] = []
        for size in 1...600 where CompleteTreeNodeCount.count(TreeNode.make(Array(1...size))) != size {
            wrong.append(size)
        }
        let allRight = wrong.isEmpty
        #expect(allRight, "sizes with the wrong count, the first few: \(Array(wrong.prefix(10)))")
    }

    @Test("A real complete tree of 300,000 nodes")
    func large() {
        let tree = TreeNode.make(Array(1...300_000))
        #expect(CompleteTreeNodeCount.count(tree) == 300_000)
    }

    @Test("Shared-subtree trees of the sizes around every power of two up to about a million")
    func aroundPowersOfTwo() {
        var cache: [Int: TreeNode] = [:]
        var wrong: [Int] = []
        for power in 2...20 {
            for size in [(1 << power) - 2, (1 << power) - 1, 1 << power, (1 << power) + 1, (1 << power) + (1 << (power - 1))] {
                let tree = sharedCompleteTree(size, cache: &cache)
                if CompleteTreeNodeCount.count(tree) != size {
                    wrong.append(size)
                }
            }
        }
        let allRight = wrong.isEmpty
        #expect(allRight, "sizes with the wrong count, the first few: \(Array(wrong.prefix(10)))")
    }

    @Test("400 million nodes: instant for O(log² n), several seconds for a solution that visits every node")
    func huge() {
        var cache: [Int: TreeNode] = [:]
        let size = 400_000_000
        let tree = sharedCompleteTree(size, cache: &cache)
        #expect(CompleteTreeNodeCount.count(tree) == size)
    }
}
