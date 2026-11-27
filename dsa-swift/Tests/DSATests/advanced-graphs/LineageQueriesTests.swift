import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private struct LineageRandom {
    var state: UInt64
    mutating func next(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int((state >> 33) % UInt64(bound))
    }
}

@Suite struct LineageQueriesTests {
    // The lesson's family tree, rooted at 0:
    //            0
    //          / | \
    //         1  2  3
    //        / \     \
    //       4   5     6
    //      /   / \     \
    //     7   8   9     10
    private let family = [-1, 0, 0, 0, 1, 1, 3, 4, 5, 5, 6]

    /// Walks up one parent at a time: O(depth) per query, fine for checking shallow trees.
    private func naiveAncestor(_ parent: [Int], _ person: Int, _ k: Int) -> Int {
        var v = person
        for _ in 0..<k {
            if v == -1 { return -1 }
            v = parent[v]
        }
        return v
    }

    private func naiveLCA(_ parent: [Int], _ a: Int, _ b: Int) -> Int {
        var ancestorsOfA = Set<Int>()
        var v = a
        while v != -1 {
            ancestorsOfA.insert(v)
            v = parent[v]
        }
        v = b
        while !ancestorsOfA.contains(v) { v = parent[v] }
        return v
    }

    @Test("Ancestors in the lesson's family")
    func familyAncestors() {
        let queries = [[9, 0], [9, 1], [9, 2], [9, 3], [9, 4], [10, 3], [10, 4], [0, 0], [0, 1], [7, 1_000_000_000]]
        #expect(LineageQueries.kthAncestors(parent: family, queries: queries) == [9, 5, 1, 0, -1, 0, -1, 0, -1, -1])
    }

    @Test("Common ancestors in the lesson's family")
    func familyCommonAncestors() {
        let queries = [[7, 9], [8, 9], [7, 10], [5, 8], [8, 5], [2, 2], [4, 1], [6, 10], [9, 3], [0, 10]]
        #expect(LineageQueries.lowestCommonAncestors(parent: family, queries: queries) == [1, 5, 0, 5, 5, 2, 1, 6, 0, 0])
    }

    @Test("One person")
    func onePerson() {
        #expect(LineageQueries.kthAncestors(parent: [-1], queries: [[0, 0], [0, 1]]) == [0, -1])
        #expect(LineageQueries.lowestCommonAncestors(parent: [-1], queries: [[0, 0]]) == [0])
    }

    @Test("Parents listed after their children")
    func parentsLater() {
        // Root 4; 3 is its child; 0, 1 and 2 are children of 3
        let parent = [3, 3, 3, 4, -1]
        #expect(LineageQueries.kthAncestors(parent: parent, queries: [[0, 1], [0, 2], [2, 3], [3, 1]]) == [3, 4, -1, 4])
        #expect(LineageQueries.lowestCommonAncestors(parent: parent, queries: [[0, 2], [1, 4], [3, 2]]) == [3, 4, 3])
    }

    @Test("A random family of 20,000, labels shuffled")
    func randomFamily() {
        var random = LineageRandom(state: 77)
        let n = 20_000
        // Person i (in creation order) has a random earlier parent; then everyone gets a shuffled label
        var label = Array(0..<n)
        for i in stride(from: n - 1, to: 0, by: -1) { label.swapAt(i, random.next(i + 1)) }
        var parent = [Int](repeating: -1, count: n)
        for i in 1..<n { parent[label[i]] = label[random.next(i)] }

        let kQueries = (0..<5_000).map { _ in [random.next(n), random.next(25)] }
        #expect(LineageQueries.kthAncestors(parent: parent, queries: kQueries)
                == kQueries.map { naiveAncestor(parent, $0[0], $0[1]) })
        let pairQueries = (0..<5_000).map { _ in [random.next(n), random.next(n)] }
        #expect(LineageQueries.lowestCommonAncestors(parent: parent, queries: pairQueries)
                == pairQueries.map { naiveLCA(parent, $0[0], $0[1]) })
    }

    @Test("A chain of 100,000 generations, 100,000 queries each way")
    func longChain() {
        // Person i's parent is i - 1, so walking up one step at a time would take billions of steps
        let n = 100_000
        let parent = (0..<n).map { $0 - 1 }
        var random = LineageRandom(state: 100)
        let kQueries = (0..<n).map { _ in [random.next(n), random.next(n)] }
        #expect(LineageQueries.kthAncestors(parent: parent, queries: kQueries)
                == kQueries.map { $0[0] - $0[1] >= 0 ? $0[0] - $0[1] : -1 })
        let pairQueries = (0..<n).map { _ in [random.next(n), random.next(n)] }
        #expect(LineageQueries.lowestCommonAncestors(parent: parent, queries: pairQueries)
                == pairQueries.map { min($0[0], $0[1]) })
    }

    @Test("A chain listed from the youngest: the root is last")
    func reversedChain() {
        let n = 100_000
        let parent = (0..<n).map { $0 == n - 1 ? -1 : $0 + 1 }
        let kQueries = [[0, 99_999], [0, 100_000], [5, 10], [99_998, 1]]
        #expect(LineageQueries.kthAncestors(parent: parent, queries: kQueries) == [99_999, -1, 15, 99_999])
        let pairQueries = [[0, 1], [12_345, 67_890], [99_999, 0], [500, 500]]
        #expect(LineageQueries.lowestCommonAncestors(parent: parent, queries: pairQueries) == [1, 67_890, 99_999, 500])
    }
}
