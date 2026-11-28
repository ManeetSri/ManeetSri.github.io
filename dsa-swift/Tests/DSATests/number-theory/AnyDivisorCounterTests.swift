import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct DivisorRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct AnyDivisorCounterTests {
    @Test("Examples and small cases", arguments: [
        (100, [2, 3, 5], 74),
        (10, [4, 6], 3),
        (30, [6, 10, 15], 8),
        (20, [1, 7], 20),
        (12, [5], 2),
        (4, [5, 7], 0),
        (50, [3, 3, 3], 16),
        (60, [2, 4, 8], 30),
    ])
    func examples(n: Int, divisors: [Int], expected: Int) {
        #expect(AnyDivisorCounter.count(upTo: n, divisors: divisors) == expected)
    }

    @Test("Matches checking every number on 400 random small inputs")
    func randomSmall() {
        var random = DivisorRandom(seed: 67)
        for _ in 0..<400 {
            let n = Int.random(in: 1...3_000, using: &random)
            let divisors = (0..<Int.random(in: 1...8, using: &random)).map { _ in Int.random(in: 1...60, using: &random) }
            let expected = (1...n).filter { k in divisors.contains { k % $0 == 0 } }.count
            #expect(AnyDivisorCounter.count(upTo: n, divisors: divisors) == expected, "n = \(n), divisors \(divisors)")
        }
    }

    @Test("Up to 10¹⁸ with the first twenty primes")
    func manyPrimes() {
        let primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]
        #expect(AnyDivisorCounter.count(upTo: 1_000_000_000_000_000_000, divisors: [2, 3, 5]) == 733_333_333_333_333_334)
        #expect(AnyDivisorCounter.count(upTo: 1_000_000_000_000_000_000, divisors: primes) == 872_202_319_624_080_142)
        #expect(AnyDivisorCounter.count(upTo: 1_000, divisors: primes) == 851)
    }

    @Test("lcms that overflow Int must count as nothing, not crash")
    func overflow() {
        let big = 1_000_000_000_000_000_000
        // lcm(10¹⁸, 10¹⁸ − 1) is about 10³⁶
        #expect(AnyDivisorCounter.count(upTo: big, divisors: [big, big - 1]) == 2)
        #expect(AnyDivisorCounter.count(upTo: big, divisors: [999_999_999_989, 999_999_999_959, 2]) == big / 2 + 1_000_000 + 1_000_000 - 500_000 - 500_000)
        let largePrimes = [999_999_937, 999_999_929, 999_999_893, 999_999_883, 999_999_797]
        #expect(AnyDivisorCounter.count(upTo: big, divisors: largePrimes) == expectedForLargePrimes(big, largePrimes))
    }

    @Test("Repeated divisors, and divisors that divide each other")
    func repeats() {
        let n = 999_999_999_999_999_999
        #expect(AnyDivisorCounter.count(upTo: n, divisors: Array(repeating: 2, count: 16)) == n / 2)
        #expect(AnyDivisorCounter.count(upTo: n, divisors: [3, 9, 27, 81, 243, 6, 12, 24]) == n / 3)
        #expect(AnyDivisorCounter.count(upTo: n, divisors: [1] + Array(repeating: 2, count: 15)) == n)
    }

    /// For five primes near 10⁹, only single primes and pairs have products up to 10¹⁸
    private func expectedForLargePrimes(_ n: Int, _ primes: [Int]) -> Int {
        var total = 0
        for i in primes.indices {
            total += n / primes[i]
            for j in (i + 1)..<primes.count {
                let product = primes[i].multipliedReportingOverflow(by: primes[j])
                if !product.overflow && product.partialValue <= n { total -= n / product.partialValue }
            }
        }
        return total
    }
}
