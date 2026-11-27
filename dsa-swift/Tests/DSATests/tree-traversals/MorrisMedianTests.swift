import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// Every node with the identities of its children, in preorder. A set of seen nodes stops the walk if
/// a leftover thread has made a loop, so a broken tree can't hang the test.
private func links(_ root: TreeNode?) -> [[ObjectIdentifier?]] {
    var result: [[ObjectIdentifier?]] = []
    var seen = Set<ObjectIdentifier>()
    var stack = [root].compactMap { $0 }
    while let node = stack.popLast() {
        guard seen.insert(ObjectIdentifier(node)).inserted else { continue }
        result.append([ObjectIdentifier(node), node.left.map(ObjectIdentifier.init), node.right.map(ObjectIdentifier.init)])
        if let right = node.right { stack.append(right) }
        if let left = node.left { stack.append(left) }
    }
    return result
}

/// The median worked out from the sorted values (DSAKit's inorder), or nil for no values.
private func expectedMedian(_ root: TreeNode?) -> Double? {
    guard let values = root?.inorder, !values.isEmpty else { return nil }
    return (Double(values[(values.count - 1) / 2]) + Double(values[values.count / 2])) / 2
}

/// A binary search tree built by inserting `values` in order, with a loop.
private func bst(_ values: [Int]) -> TreeNode? {
    var root: TreeNode? = nil
    for value in values {
        guard var node = root else { root = TreeNode(value); continue }
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

/// The problem with the median and the tree's links afterwards, or nil if both are right.
private func problem(_ root: TreeNode?, _ label: String) -> String? {
    let before = links(root)
    let expected = expectedMedian(root)
    let actual = MorrisMedian.median(of: root)
    if actual != expected { return "\(label): got \(String(describing: actual)), expected \(String(describing: expected))" }
    if links(root) != before { return "\(label): the tree's links changed" }
    return nil
}

/// Checks the median and that the tree's links are exactly as before.
private func check(_ root: TreeNode?, _ label: String) {
    let found = problem(root, label)
    #expect(found == nil, "\(found ?? "")")
}

@Suite struct MorrisMedianTests {
    @Test("The examples", arguments: [
        ([4, 2, 6, 1, 3, 5, 7], 4.0 as Double?),
        ([4, 2, 6, 1, 3, 5], 3.5),
        ([10, 5, nil, 1], 5.0),
        ([8], 8.0),
        ([-3, -7], -5.0),
        ([], nil),
    ] as [([Int?], Double?)])
    func examples(levelOrder: [Int?], expected: Double?) {
        let root = TreeNode.make(levelOrder)
        let before = links(root)
        #expect(MorrisMedian.median(of: root) == expected)
        #expect(links(root) == before, "the tree's links changed")
        #expect(root?.levelOrder ?? [] == levelOrder)
    }

    @Test("Repeated values and extremes")
    func repeatsAndExtremes() {
        check(bst([5, 5, 5, 5]), "four 5s")
        check(bst([2, 1, 2, 3, 2]), "several 2s")
        check(bst([1_000_000_000, -1_000_000_000]), "the extremes")
        check(bst([1_000_000_000, 999_999_999, 1_000_000_000, 999_999_999]), "large even count")
    }

    @Test("Calling it twice gives the same answer: the first call left the tree intact")
    func twice() {
        let root = bst([50, 30, 70, 20, 40, 60, 80, 35, 45, 65])
        let first = MorrisMedian.median(of: root)
        #expect(first == expectedMedian(root))
        #expect(MorrisMedian.median(of: root) == first)
    }

    @Test("Hundreds of random small trees")
    func manyRandom() {
        var state: UInt64 = 35
        var failures: [String] = []
        for size in 1...300 {
            var values: [Int] = []
            for _ in 0..<(size % 25 + 1) {
                state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
                values.append(Int(state >> 33) % 40 - 20)
            }
            if let found = problem(bst(values), "inserting \(values)"), failures.count < 3 {
                failures.append(found)
            }
        }
        #expect(failures.isEmpty, "\(failures)")
    }

    @Test("Chains 100,000 levels deep: leaning left, leaning right and zigzagging")
    func deepChains() {
        let n = 100_000
        let left = TreeNode(n)
        var node = left
        for value in stride(from: n - 1, through: 1, by: -1) {       // each smaller value hangs left
            let child = TreeNode(value)
            node.left = child
            node = child
        }
        check(left, "leaning left")
        let right = TreeNode(1)
        node = right
        for value in 2...n {                                          // each larger value hangs right
            let child = TreeNode(value)
            node.right = child
            node = child
        }
        check(right, "leaning right")
        // 1, n, 2, n − 1, …: each value is the only child of the one before, alternating sides
        let zigzag = TreeNode(1)
        node = zigzag
        var low = 2
        var high = n
        var goRight = true
        while low <= high {
            let child = TreeNode(goRight ? high : low)
            if goRight { node.right = child; high -= 1 } else { node.left = child; low += 1 }
            node = child
            goRight.toggle()
        }
        check(zigzag, "zigzag")
    }

    @Test("A random tree of 100,000 nodes")
    func large() {
        var state: UInt64 = 350
        let values = (0..<100_000).map { _ -> Int in
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Int(state >> 33) % 2_000_000_000 - 1_000_000_000
        }
        check(bst(values), "random")
    }
}
