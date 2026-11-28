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

/// A tree of `count` nodes in a random shape, with values from `values`.
private func randomTree(_ count: Int, values: ClosedRange<Int>, generator: inout SeededGenerator) -> TreeNode? {
    guard count > 0 else { return nil }
    let root = TreeNode(Int.random(in: values, using: &generator))
    for _ in 1..<count {
        let value = Int.random(in: values, using: &generator)
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

/// Serialises and deserialises, and returns the rebuilt tree's level order.
private func roundTrip(_ tree: TreeNode?) -> [Int?] {
    TreeStringCodec.deserialise(TreeStringCodec.serialise(tree))?.levelOrder ?? []
}

@Suite struct TreeStringCodecTests {
    @Test("Small trees come back unchanged", arguments: [
        [1],
        [1, 2, 3, nil, nil, 4, 5],
        [-7, nil, 12, 0],
        [2, 2, 2, nil, 2],
        [10, 20, nil, 30, nil, 40],
        [5, nil, 6, nil, 7, nil, 8],
        [1, 2, 3, 4, 5, 6, 7],
        [Int.min, Int.max, 0],
        [0, 0, 0, 0, nil, nil, 0],
    ] as [[Int?]])
    func examples(levelOrder: [Int?]) {
        #expect(roundTrip(TreeNode.make(levelOrder)) == levelOrder)
    }

    @Test("The empty tree comes back empty")
    func empty() {
        #expect(TreeStringCodec.deserialise(TreeStringCodec.serialise(nil)) == nil)
    }

    @Test("Different shapes with the same values give different strings")
    func shapesDiffer() {
        let shapes: [[Int?]] = [[1, 2], [1, nil, 2], [2, 1], [2, nil, 1], [1, 2, 3], [1, 2, nil, 3], [1, nil, 2, nil, 3]]
        let strings = shapes.map { TreeStringCodec.serialise(TreeNode.make($0)) }
        #expect(Set(strings).count == shapes.count)
    }

    @Test("Deserialising builds new nodes, and works long after serialising")
    func independent() throws {
        let first = try #require(TreeNode.make([3, 1, 4, nil, 5]))
        let firstText = TreeStringCodec.serialise(first)
        let second = TreeNode.make([9, 8, 7, 6])
        let secondText = TreeStringCodec.serialise(second)
        first.left?.value = 100                              // changing the original changes nothing
        let rebuilt = try #require(TreeStringCodec.deserialise(firstText))
        #expect(rebuilt !== first)
        #expect(rebuilt.levelOrder == [3, 1, 4, nil, 5])
        #expect(TreeStringCodec.deserialise(secondText)?.levelOrder == [9, 8, 7, 6])
    }

    @Test("400 random trees with negative and repeated values")
    func randomTrees() {
        var generator = SeededGenerator(state: 17)
        var firstMismatch: String? = nil
        for round in 0..<400 {
            let range = round % 2 == 0 ? -3...3 : -1_000_000...1_000_000
            let tree = randomTree(round % 60, values: range, generator: &generator)
            let original = tree?.levelOrder ?? []
            if roundTrip(tree) != original {
                firstMismatch = firstMismatch ?? "\(original)"
            }
        }
        #expect(firstMismatch == nil, "the first tree that didn't come back")
    }

    @Test("A perfect tree of 131,071 nodes")
    func largePerfect() {
        let values: [Int?] = Array(1...131_071)
        let matches = roundTrip(TreeNode.make(values)) == values
        #expect(matches, "the tree didn't come back unchanged")
    }

    @Test("A random tree of 150,000 nodes with values up to a billion")
    func largeRandom() {
        var generator = SeededGenerator(state: 9)
        let tree = randomTree(150_000, values: -1_000_000_000...1_000_000_000, generator: &generator)
        let matches = roundTrip(tree) == tree?.levelOrder
        #expect(matches, "the tree didn't come back unchanged")
    }

    @Test("Chains 500 nodes deep, to the left, to the right and zigzagging")
    func chains() {
        for shape in 0..<3 {
            var top: TreeNode? = nil
            for value in 0..<500 {
                let goLeft = shape == 0 || (shape == 2 && value % 2 == 0)
                top = goLeft ? TreeNode(value, left: top) : TreeNode(value, right: top)
            }
            let matches = roundTrip(top) == top?.levelOrder
            #expect(matches, "chain shape \(shape) didn't come back unchanged")
        }
    }
}
