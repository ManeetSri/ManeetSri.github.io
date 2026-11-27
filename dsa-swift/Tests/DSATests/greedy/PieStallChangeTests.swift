import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct StallRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PieStallChangeTests {
    /// Tries both ways of changing every 20 (a ten and a five, or three fives), so it finds a way
    /// through if any exists. Exponential, so only for short queues.
    private func exhaustive(_ payments: [Int], from index: Int = 0, fives: Int = 0, tens: Int = 0) -> Bool {
        if index == payments.count { return true }
        switch payments[index] {
        case 5:
            return exhaustive(payments, from: index + 1, fives: fives + 1, tens: tens)
        case 10:
            return fives >= 1 && exhaustive(payments, from: index + 1, fives: fives - 1, tens: tens + 1)
        default:
            if tens >= 1 && fives >= 1 && exhaustive(payments, from: index + 1, fives: fives - 1, tens: tens - 1) {
                return true
            }
            return fives >= 3 && exhaustive(payments, from: index + 1, fives: fives - 3, tens: tens)
        }
    }

    @Test("Examples and small cases", arguments: [
        ([5, 5, 5, 5, 10, 20, 10, 10], true),
        ([5, 10, 5, 20, 20], false),
        ([5, 10, 5, 5, 20], true),
        ([5, 5, 10], true),
        ([10], false),
        ([20], false),
        ([5, 20], false),
        ([5, 5, 5, 20], true),
        ([5, 10, 20], false),
        ([5, 5, 10, 10, 20], false),
        ([], true),
        ([5, 5, 5, 10, 20, 5, 10], true),
    ] as [([Int], Bool)])
    func examples(payments: [Int], expected: Bool) {
        #expect(PieStallChange.canGiveChange(payments) == expected)
    }

    @Test("Matches trying every way to give change on 1,000 random queues")
    func randomSmall() {
        var random = StallRandom(seed: 50)
        for _ in 0..<1_000 {
            // Mostly fives, so many queues succeed and the choice for each 20 matters
            let payments = (0..<Int.random(in: 1...14, using: &random)).map { _ -> Int in
                let roll = Int.random(in: 0..<10, using: &random)
                return roll < 5 ? 5 : roll < 8 ? 10 : 20
            }
            #expect(PieStallChange.canGiveChange(payments) == exhaustive(payments), "payments \(payments)")
        }
    }

    @Test("100,000 customers")
    func large() {
        let n = 100_000
        #expect(PieStallChange.canGiveChange(Array(repeating: 5, count: n)))
        // In each 5, 5, 10, 20 round, the 10 takes one five and the 20 takes the ten and the other five,
        // so the till is empty after every round
        let rounds = (0..<(n / 4 - 1)).flatMap { _ in [5, 5, 10, 20] }
        #expect(PieStallChange.canGiveChange(rounds))
        #expect(!PieStallChange.canGiveChange(rounds + [20]))
        #expect(!PieStallChange.canGiveChange(rounds + [10]))
        #expect(PieStallChange.canGiveChange([5] + rounds + [10]))
        // Four fives then a ten and a twenty, again and again: only works if each 20 takes the ten
        let tenFirst = (0..<(n / 10)).flatMap { _ in [5, 5, 5, 5, 10, 20, 10, 10, 5, 20] }
        #expect(PieStallChange.canGiveChange(tenFirst) == exhaustiveIterative(tenFirst))
    }

    /// The greedy state after each customer, checked step by step without recursion, for long queues.
    /// Keeps every reachable (fives, tens) pair, which stays small because tens never exceed fives used.
    private func exhaustiveIterative(_ payments: [Int]) -> Bool {
        var states: Set<[Int]> = [[0, 0]]
        for note in payments {
            var nextStates: Set<[Int]> = []
            for state in states {
                let (fives, tens) = (state[0], state[1])
                switch note {
                case 5: nextStates.insert([fives + 1, tens])
                case 10: if fives >= 1 { nextStates.insert([fives - 1, tens + 1]) }
                default:
                    if tens >= 1 && fives >= 1 { nextStates.insert([fives - 1, tens - 1]) }
                    if fives >= 3 { nextStates.insert([fives - 3, tens]) }
                }
            }
            if nextStates.isEmpty { return false }
            states = nextStates
        }
        return true
    }
}
