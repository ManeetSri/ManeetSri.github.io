import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct DigitRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RangeDigitSumCountTests {
    private static let quintillion = 1_000_000_000_000_000_000

    /// Coefficients of (1 + x + … + x⁹)^digits: how many digit strings of that length have each sum
    private func digitStrings(_ digits: Int) -> [Int] {
        var poly = [1]
        for _ in 0..<digits {
            var next = [Int](repeating: 0, count: poly.count + 9)
            for (sum, ways) in poly.enumerated() {
                for digit in 0...9 {
                    next[sum + digit] += ways
                }
            }
            poly = next
        }
        return poly
    }

    @Test("Examples and small cases", arguments: [
        (0, 253, 7, 21),
        (100, 200, 5, 5),
        (1, 1_000_000_000_000_000_000, 1, 19),
        (0, 0, 0, 1),
        (1, 1_000, 0, 0),
        (5, 5, 5, 1),
        (1, 9, 10, 0),
        (0, 1_000_000_000_000_000_000, 200, 0),
        (1_000_000_000_000_000_000, 1_000_000_000_000_000_000, 1, 1),
        (999_999_999_999_999_999, 999_999_999_999_999_999, 162, 1),
    ] as [(Int, Int, Int, Int)])
    func examples(low: Int, high: Int, digitSum: Int, expected: Int) {
        #expect(RangeDigitSumCount.count(from: low, to: high, digitSum: digitSum) == expected)
    }

    @Test("Matches counting one by one below 200,000")
    func randomSmall() {
        let limit = 200_000
        var digitSum = [Int](repeating: 0, count: limit)
        for x in 1..<limit {
            digitSum[x] = digitSum[x / 10] + x % 10
        }
        var random = DigitRandom(seed: 58)
        for target in [0, 1, 2, 7, 13, 20, 27, 36, 41, 45, 46, 50] {
            var prefix = [0]                                 // prefix[i] = matches among 0..<i
            for x in 0..<limit {
                prefix.append(prefix[x] + (digitSum[x] == target ? 1 : 0))
            }
            for _ in 0..<40 {
                let a = Int.random(in: 0..<limit, using: &random)
                let b = Int.random(in: 0..<limit, using: &random)
                let (low, high) = (min(a, b), max(a, b))
                #expect(RangeDigitSumCount.count(from: low, to: high, digitSum: target) == prefix[high + 1] - prefix[low])
            }
        }
    }

    @Test("Every sum up to 10^k - 1 matches counting digit strings")
    func powersOfTen() {
        for digits in [1, 2, 7, 18] {
            let ways = digitStrings(digits)
            var limit = 1
            for _ in 0..<digits { limit *= 10 }
            for target in 0...min(200, 9 * digits) {
                #expect(RangeDigitSumCount.count(from: 0, to: limit - 1, digitSum: target) == ways[target])
            }
        }
    }

    @Test("Ranges split anywhere add up")
    func additive() {
        var random = DigitRandom(seed: 2_058)
        for _ in 0..<50 {
            var points = (0..<3).map { _ in Int.random(in: 0...Self.quintillion, using: &random) }.sorted()
            if points[1] == points[2] { points[1] -= 1 }
            if points[0] > points[1] { points[0] = points[1] }
            let target = Int.random(in: 0...170, using: &random)
            let whole = RangeDigitSumCount.count(from: points[0], to: points[2], digitSum: target)
            let left = RangeDigitSumCount.count(from: points[0], to: points[1], digitSum: target)
            let right = RangeDigitSumCount.count(from: points[1] + 1, to: points[2], digitSum: target)
            #expect(whole == left + right)
        }
        // And one known total: all 18-digit-or-shorter numbers with digit sum 81
        #expect(RangeDigitSumCount.count(from: 0, to: Self.quintillion, digitSum: 81) == digitStrings(18)[81])
    }
}
