import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct LookupTreeRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SpellcheckLookupTreeTests {
    /// Build every BST shape and add up each search's comparisons directly: keys i..<j hang at
    /// `depth`, and a gap with no key below it costs the depth of its parent
    private func everyTree(_ hits: [Int], _ misses: [Int], _ i: Int, _ j: Int, depth: Int) -> Int {
        if i == j { return misses[i] * (depth - 1) }
        var best = Int.max
        for root in i..<j {
            let cost = hits[root] * depth
                + everyTree(hits, misses, i, root, depth: depth + 1)
                + everyTree(hits, misses, root + 1, j, depth: depth + 1)
            best = min(best, cost)
        }
        return best
    }

    /// Top-down over closed ranges first...last, summing each range's searches with a loop
    private func memoised(_ hits: [Int], _ misses: [Int]) -> Int {
        let n = hits.count
        var memo: [[Int?]] = Array(repeating: Array(repeating: nil, count: n + 1), count: n + 1)
        func best(_ first: Int, _ last: Int) -> Int {         // keys first...last; empty when last < first
            if last < first { return 0 }
            if let known = memo[first][last] { return known }
            var searches = misses[last + 1]
            for key in first...last { searches += hits[key] + misses[key] }
            var cheapest = Int.max
            for root in first...last {
                cheapest = min(cheapest, best(first, root - 1) + best(root + 1, last))
            }
            memo[first][last] = cheapest + searches
            return cheapest + searches
        }
        return best(0, n - 1)
    }

    @Test("Examples and small cases", arguments: [
        ([4, 2, 6, 3], [0, 0, 0, 0, 0], 26),           // the lesson's keys 10, 20, 30, 40
        ([1, 1], [0, 0, 10], 13),                       // misses after the last key pull it to the root
        ([], [7], 0),                                   // an empty tree makes no comparisons
        ([3], [1, 2], 6),
        ([5], [0, 0], 5),
        ([1, 1, 1], [0, 0, 0, 0], 5),
        ([0, 0, 0], [1, 1, 1, 1], 8),
        ([10, 0, 0, 0], [0, 0, 0, 0, 0], 10),
        ([2, 3], [4, 0, 1], 14),
    ] as [([Int], [Int], Int)])
    func examples(hits: [Int], misses: [Int], expected: Int) {
        #expect(SpellcheckLookupTree.cheapestCost(hits: hits, misses: misses) == expected)
    }

    @Test("Matches trying every tree shape on 300 random dictionaries")
    func randomSmall() {
        var random = LookupTreeRandom(seed: 1_971)
        for _ in 0..<300 {
            let n = Int.random(in: 0...7, using: &random)
            let hits = (0..<n).map { _ in Int.random(in: 0...20, using: &random) }
            let misses = (0...n).map { _ in Int.random(in: 0...20, using: &random) }
            #expect(SpellcheckLookupTree.cheapestCost(hits: hits, misses: misses) == everyTree(hits, misses, 0, n, depth: 1))
        }
    }

    @Test("120 keys match a memoised top-down search")
    func mediumRandom() {
        var random = LookupTreeRandom(seed: 120)
        for _ in 0..<2 {
            let hits = (0..<120).map { _ in Int.random(in: 0...1_000_000, using: &random) }
            let misses = (0...120).map { _ in Int.random(in: 0...1_000_000, using: &random) }
            #expect(SpellcheckLookupTree.cheapestCost(hits: hits, misses: misses) == memoised(hits, misses))
        }
    }

    @Test("255 equally popular keys give a perfectly balanced tree")
    func large() {
        // 1 key at depth 1, 2 at depth 2, …, 128 at depth 8: 1·1 + 2·2 + 4·3 + … + 128·8 = 1,793
        let ones = Array(repeating: 1, count: 255)
        let none = Array(repeating: 0, count: 256)
        #expect(SpellcheckLookupTree.cheapestCost(hits: ones, misses: none) == 1_793)
        // Only misses: all 256 gaps end below the 128 leaves, after 8 comparisons each
        #expect(SpellcheckLookupTree.cheapestCost(hits: Array(repeating: 0, count: 255), misses: Array(repeating: 1, count: 256)) == 2_048)
    }
}
