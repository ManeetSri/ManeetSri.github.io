import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BiggestRiseTests {
    // The slow, all-pairs definition, for checking small inputs
    static func bruteForce(_ readings: [Int]) -> Int? {
        var best: Int?
        for i in 0..<readings.count {
            for j in (i + 1)..<readings.count {
                let rise = readings[j] - readings[i]
                best = max(best ?? rise, rise)
            }
        }
        return best
    }

    // Deterministic pseudo-random readings between -1,000 and 1,000
    static func readings(count: Int, seed: Int) -> [Int] {
        var state = seed
        return (0..<count).map { _ in
            state = (state &* 1_103_515_245 &+ 12_345) & 0x7FFF_FFFF
            return state % 2_001 - 1_000
        }
    }

    @Test("Examples", arguments: [
        ([4, 1, 7, 3, 9, 2], 8),
        ([3, 8], 5),
        ([5, 5, 5], 0),
        ([2, 3, 1, 10], 9),
        ([10, 1, 3], 2),
    ])
    func examples(readings: [Int], expected: Int) {
        #expect(BiggestRise.biggestRise(in: readings) == expected)
    }

    @Test("A falling series gives the smallest drop, which is negative")
    func falling() {
        #expect(BiggestRise.biggestRise(in: [9, 7, 4, 1]) == -2)
        #expect(BiggestRise.biggestRise(in: [8, 3]) == -5)
    }

    @Test("Fewer than two readings has no answer")
    func tooShort() {
        #expect(BiggestRise.biggestRise(in: []) == nil)
        #expect(BiggestRise.biggestRise(in: [42]) == nil)
    }

    @Test("The rise must go forwards in time")
    func orderMatters() {
        // The largest value comes before the smallest, so the answer isn't max − min
        #expect(BiggestRise.biggestRise(in: [100, 50, 60, 1]) == 10)
    }

    @Test("Handles the extremes of the allowed range")
    func extremes() {
        #expect(BiggestRise.biggestRise(in: [-1_000_000_000, 1_000_000_000]) == 2_000_000_000)
        #expect(BiggestRise.biggestRise(in: [1_000_000_000, -1_000_000_000]) == -2_000_000_000)
    }

    @Test("Matches the all-pairs answer on 300 small inputs")
    func matchesBruteForce() {
        let inputs = (1...300).map { Self.readings(count: 2 + $0 % 40, seed: $0) }
        let wrong = inputs.filter { BiggestRise.biggestRise(in: $0) != Self.bruteForce($0) }
        #expect(wrong.isEmpty, "\(wrong.count) wrong, for example \(wrong.first ?? [])")
    }

    @Test("Stays fast on 100,000 readings")
    func large() {
        let input = Self.readings(count: 100_000, seed: 2_024)
        // An independent check: the best rise from each reading is the largest reading after it
        var largestAfter = input[input.count - 1]
        var expected = input[input.count - 1] - input[input.count - 2]
        for i in stride(from: input.count - 2, through: 0, by: -1) {
            expected = max(expected, largestAfter - input[i])
            largestAfter = max(largestAfter, input[i])
        }
        #expect(BiggestRise.biggestRise(in: input) == expected)
    }
}
