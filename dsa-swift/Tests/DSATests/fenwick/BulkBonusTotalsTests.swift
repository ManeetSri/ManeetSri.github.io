import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BonusRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BulkBonusTotalsTests {
    /// Pays and adds up desk by desk. Slow, but clearly right.
    private func reference(_ initial: [Int], _ operations: [[Int]]) -> [Int] {
        var paid = initial
        var answers: [Int] = []
        for operation in operations {
            if operation[0] == 0 {
                for desk in operation[1]...operation[2] { paid[desk] += operation[3] }
            } else {
                answers.append(paid[operation[1]...operation[2]].reduce(0, +))
            }
        }
        return answers
    }

    /// A fast reference: DSAKit's LazySegmentTree, a different technique from two Fenwick trees.
    private func fastReference(_ initial: [Int], _ operations: [[Int]]) -> [Int] {
        var paid = LazySegmentTree(initial)
        var answers: [Int] = []
        for operation in operations {
            if operation[0] == 0 {
                paid.add(operation[3], to: operation[1]...operation[2])
            } else {
                answers.append(paid.sum(in: operation[1]...operation[2]))
            }
        }
        return answers
    }

    @Test("The example from the statement")
    func example() {
        let initial = [10, 0, 5, 0, 20]
        let operations = [[1, 0, 4], [0, 1, 3, 4], [1, 2, 4], [0, 0, 4, -1], [1, 0, 1], [1, 3, 3]]
        #expect(BulkBonusTotals.process(initial: initial, operations: operations) == [35, 33, 12, 3])
    }

    @Test("Small cases", arguments: [
        ([7], [[1, 0, 0], [0, 0, 0, 3], [1, 0, 0]], [7, 10]),
        ([0, 0, 0], [[0, 0, 2, 5], [0, 2, 2, 1], [1, 0, 2], [1, 2, 2], [1, 0, 1]], [16, 6, 10]),
        ([1, 2, 3, 4], [[0, 3, 3, 10], [1, 0, 3], [1, 3, 3]], [20, 14]),
        ([1, 2, 3], [[0, 0, 2, 1]], []),
    ] as [([Int], [[Int]], [Int])])
    func small(initial: [Int], operations: [[Int]], expected: [Int]) {
        #expect(BulkBonusTotals.process(initial: initial, operations: operations) == expected)
    }

    @Test("Matches paying desk by desk on 300 small random offices")
    func randomSmall() {
        var random = BonusRandom(seed: 66)
        for _ in 0..<300 {
            let count = Int.random(in: 1...12, using: &random)
            let initial = (0..<count).map { _ in Int.random(in: -20...20, using: &random) }
            let operations = (0..<Int.random(in: 1...30, using: &random)).map { _ -> [Int] in
                let a = Int.random(in: 0..<count, using: &random), b = Int.random(in: 0..<count, using: &random)
                return Bool.random(using: &random)
                    ? [0, min(a, b), max(a, b), Int.random(in: -10...10, using: &random)]
                    : [1, min(a, b), max(a, b)]
            }
            #expect(BulkBonusTotals.process(initial: initial, operations: operations) == reference(initial, operations))
        }
    }

    @Test("100,000 desks and 100,000 wide bonuses and questions")
    func large() {
        // Paying desk by desk would take about 3 × 10⁹ steps
        var random = BonusRandom(seed: 2_032)
        let count = 100_000
        let initial = (0..<count).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        let operations = (0..<100_000).map { _ -> [Int] in
            let a = Int.random(in: 0..<count, using: &random), b = Int.random(in: 0..<count, using: &random)
            return Bool.random(using: &random)
                ? [0, min(a, b), max(a, b), Int.random(in: -1_000_000...1_000_000, using: &random)]
                : [1, min(a, b), max(a, b)]
        }
        #expect(BulkBonusTotals.process(initial: initial, operations: operations) == fastReference(initial, operations))
    }
}
