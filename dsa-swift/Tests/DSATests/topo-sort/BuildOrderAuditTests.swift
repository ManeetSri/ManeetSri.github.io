import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BuildAuditRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BuildOrderAuditTests {
    /// Check each step against the whole input directly: slow, but clearly right
    private func reference(_ targets: Int, _ needs: [[Int]], _ order: [Int]) -> Int {
        for (step, target) in order.enumerated() {
            let earlier = order[..<step]
            if target < 0 || target >= targets || earlier.contains(target) { return step }
            for pair in needs where pair[0] == target && !earlier.contains(pair[1]) {
                return step
            }
        }
        return Set(order).count == targets ? -1 : order.count
    }

    /// A random DAG over shuffled labels, as `needs` pairs, plus one valid build order of it
    private func randomDAG(_ targets: Int, pairs: Int, using random: inout BuildAuditRandom) -> (needs: [[Int]], order: [Int]) {
        let order = Array(0..<targets).shuffled(using: &random)
        var needs: [[Int]] = []
        if targets >= 2 {
            for _ in 0..<pairs {
                let first = Int.random(in: 0..<targets, using: &random)
                let second = Int.random(in: 0..<targets, using: &random)
                if first == second { continue }
                needs.append([order[max(first, second)], order[min(first, second)]])   // later needs earlier
            }
        }
        return (needs, order)
    }

    @Test("Examples and small cases", arguments: [
        (4, [[1, 0], [2, 0], [3, 1], [3, 2]], [0, 2, 1, 3], -1),
        (4, [[1, 0], [2, 0], [3, 1], [3, 2]], [0, 1, 3, 2], 2),       // 3 needs 2, which comes later
        (4, [[1, 0], [2, 0], [3, 1], [3, 2]], [0, 1, 2], 3),          // target 3 is never built
        (4, [[1, 0], [2, 0], [3, 1], [3, 2]], [0, 0, 1, 2, 3], 1),    // 0 built twice
        (3, [], [2, 7, 0, 1], 1),                                     // 7 isn't a target
        (2, [[0, 0]], [1, 0], 1),                                     // 0 needs itself
        (3, [[0, 1], [1, 2], [2, 0]], [0, 1, 2], 0),                  // a cycle: nothing can go first
        (1, [], [0], -1),
        (1, [], [], 0),
        (3, [], [2, 0, 1], -1),
        (3, [[2, 1], [2, 1], [1, 0]], [0, 1, 2], -1),                 // repeated pairs
        (3, [[2, 1], [1, 0]], [2, 1, 0], 0),                          // arrows read the wrong way round
        (3, [], [-1, 0, 1, 2], 0),
        (2, [[1, 0]], [0, 1, 1], 2),
    ] as [(Int, [[Int]], [Int], Int)])
    func examples(targets: Int, needs: [[Int]], order: [Int], expected: Int) {
        #expect(BuildOrderAudit.firstBadStep(targets: targets, needs: needs, order: order) == expected)
    }

    @Test("Valid orders pass, and a swap is caught where it happens")
    func validAndSwapped() {
        var random = BuildAuditRandom(seed: 43)
        for _ in 0..<200 {
            let targets = Int.random(in: 2...12, using: &random)
            let (needs, order) = randomDAG(targets, pairs: Int.random(in: 0...25, using: &random), using: &random)
            #expect(BuildOrderAudit.firstBadStep(targets: targets, needs: needs, order: order) == -1)

            var swapped = order
            let i = Int.random(in: 0..<targets, using: &random)
            let j = Int.random(in: 0..<targets, using: &random)
            swapped.swapAt(i, j)
            #expect(BuildOrderAudit.firstBadStep(targets: targets, needs: needs, order: swapped) == reference(targets, needs, swapped))
        }
    }

    @Test("Matches a direct check on 500 random orders")
    func randomSmall() {
        var random = BuildAuditRandom(seed: 2_026)
        for _ in 0..<500 {
            let targets = Int.random(in: 1...8, using: &random)
            let needs = (0..<Int.random(in: 0...10, using: &random)).map { _ in
                [Int.random(in: 0..<targets, using: &random), Int.random(in: 0..<targets, using: &random)]
            }
            let order = (0..<Int.random(in: 0...10, using: &random)).map { _ in Int.random(in: -1...targets, using: &random) }
            #expect(BuildOrderAudit.firstBadStep(targets: targets, needs: needs, order: order) == reference(targets, needs, order))

            // Also a shuffled permutation, which only fails on dependencies
            let permutation = Array(0..<targets).shuffled(using: &random)
            #expect(BuildOrderAudit.firstBadStep(targets: targets, needs: needs, order: permutation) == reference(targets, needs, permutation))
        }
    }

    @Test("100,000 targets with 250,000 needs")
    func large() {
        // A hidden chain through every target, plus random extra needs that respect it
        var random = BuildAuditRandom(seed: 100_000)
        let targets = 100_000
        let order = Array(0..<targets).shuffled(using: &random)
        var needs: [[Int]] = (1..<targets).map { [order[$0], order[$0 - 1]] }
        while needs.count < 250_000 {
            let first = Int.random(in: 0..<targets, using: &random)
            let second = Int.random(in: 0..<targets, using: &random)
            if first != second {
                needs.append([order[max(first, second)], order[min(first, second)]])
            }
        }
        needs.shuffle(using: &random)
        #expect(BuildOrderAudit.firstBadStep(targets: targets, needs: needs, order: order) == -1)

        // Swap two neighbours late in the order: the second of them needs the first
        var swapped = order
        swapped.swapAt(77_777, 77_778)
        #expect(BuildOrderAudit.firstBadStep(targets: targets, needs: needs, order: swapped) == 77_777)

        // Stop one short, then repeat the first target at the end
        #expect(BuildOrderAudit.firstBadStep(targets: targets, needs: needs, order: Array(order.dropLast())) == targets - 1)
        #expect(BuildOrderAudit.firstBadStep(targets: targets, needs: needs, order: order + [order[0]]) == targets)
    }
}
