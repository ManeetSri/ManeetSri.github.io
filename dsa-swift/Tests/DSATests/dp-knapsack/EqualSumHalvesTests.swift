import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct HalvesRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct EqualSumHalvesTests {
    /// Brute force: does any subset add up to exactly half of the total?
    private func bruteForce(_ numbers: [Int]) -> Bool {
        let total = numbers.reduce(0, +)
        for mask in 0..<(1 << numbers.count) {
            var sum = 0
            for i in numbers.indices where mask & (1 << i) != 0 {
                sum += numbers[i]
            }
            if 2 * sum == total { return true }
        }
        return false
    }

    @Test("Examples and edge cases", arguments: [
        ([4, 7, 2, 5, 6], true),
        ([3, 5, 9, 4, 1], false),
        ([2, 3, 4], false),
        ([1, 2, 9], false),
        ([8, 8], true),
        ([7], false),
        ([1, 1], true),
        ([2, 2, 3, 5], false),
        ([3, 1, 1, 2, 2, 1], true),
        ([100, 99, 1], true),
    ] as [([Int], Bool)])
    func examples(numbers: [Int], expected: Bool) {
        #expect(EqualSumHalves.canSplit(numbers) == expected)
    }

    @Test("Matches brute force on 300 small random lists")
    func randomSmall() {
        var random = HalvesRandom(seed: 1_975)
        for _ in 0..<300 {
            let n = Int.random(in: 1...12, using: &random)
            let numbers = (0..<n).map { _ in Int.random(in: 1...30, using: &random) }
            #expect(EqualSumHalves.canSplit(numbers) == bruteForce(numbers), "\(numbers)")
        }
    }

    @Test("200 numbers up to 500")
    func large() {
        var random = HalvesRandom(seed: 75)

        // Every number twice: one copy of each makes a half
        var doubled = (0..<100).map { _ in Int.random(in: 1...500, using: &random) }
        doubled += doubled
        doubled.shuffle(using: &random)
        #expect(EqualSumHalves.canSplit(doubled))

        // Multiples of 4 and a single 2: the total is even, but half of it is odd and no subset is
        var noHalf = (0..<149).map { _ in 4 * Int.random(in: 1...125, using: &random) }
        noHalf.append(2)
        noHalf.shuffle(using: &random)
        #expect(!EqualSumHalves.canSplit(noHalf))

        #expect(EqualSumHalves.canSplit(Array(repeating: 1, count: 200)))

        // 99 × 500 is even, but half of it would need 49.5 of the 500s
        #expect(!EqualSumHalves.canSplit(Array(repeating: 500, count: 99)))
        #expect(EqualSumHalves.canSplit(Array(repeating: 500, count: 98) + [250, 250]))
    }
}
