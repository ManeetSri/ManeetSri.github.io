import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MaxXorPairTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Every pair: O(n²), for small inputs.
    static func bruteForce(_ numbers: [Int]) -> Int {
        var best = 0
        for i in numbers.indices {
            for j in i..<numbers.count {
                best = max(best, numbers[i] ^ numbers[j])
            }
        }
        return best
    }

    /// A different fast method: decide the answer's bits from the top, checking with a set of
    /// prefixes whether some pair can produce the answer so far with this bit set.
    static func prefixSets(_ numbers: [Int]) -> Int {
        var answer = 0
        var mask = 0
        for bit in stride(from: 30, through: 0, by: -1) {
            mask |= 1 << bit
            let prefixes = Set(numbers.map { $0 & mask })
            let candidate = answer | (1 << bit)
            if prefixes.contains(where: { prefixes.contains($0 ^ candidate) }) {
                answer = candidate
            }
        }
        return answer
    }

    @Test("Examples from the statement", arguments: [
        ([6, 13, 9, 20, 3], 29),
        ([7], 0),
        ([4, 4, 4], 0),
        ([0, 2_147_483_647], 2_147_483_647),
        ([1, 2], 3),
        ([8, 1, 2, 12], 14),
    ])
    func examples(numbers: [Int], expected: Int) {
        #expect(MaxXorPair.largestXor(in: numbers) == expected)
    }

    @Test("The highest bit decides: 16 and 15 beat everything else")
    func highBit() {
        #expect(MaxXorPair.largestXor(in: [15, 14, 13, 16, 12]) == 31)
    }

    @Test("Small random arrays agree with checking every pair")
    func smallRandom() {
        var steps = Steps(seed: 31)
        var mismatches = 0
        for round in 0..<300 {
            let count = 1 + steps.next(below: 30)
            let limit = round % 2 == 0 ? 64 : 2_147_483_648
            let numbers = (0..<count).map { _ in steps.next(below: limit) }
            if MaxXorPair.largestXor(in: numbers) != Self.bruteForce(numbers) { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("50,000 numbers across the full range")
    func largeFullRange() {
        var steps = Steps(seed: 2)
        let numbers = (0..<50_000).map { _ in steps.next(below: 2_147_483_648) }
        #expect(MaxXorPair.largestXor(in: numbers) == Self.prefixSets(numbers))
    }

    @Test("50,000 numbers that share their top bits")
    func largeSharedTopBits() {
        var steps = Steps(seed: 3)
        // Every number has bit 30 set and bits 29 to 20 equal to 0b1011001110, so the answer is below 2^20
        let numbers = (0..<50_000).map { _ in (1 << 30) | (0b10_1100_1110 << 20) | steps.next(below: 1 << 20) }
        let expected = Self.prefixSets(numbers)
        #expect(expected < 1 << 20)
        #expect(MaxXorPair.largestXor(in: numbers) == expected)
    }
}
