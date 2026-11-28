import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct GrowthRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RecurrenceGrowthReaderTests {
    private func check(_ a: Int, _ b: Int, _ d: Int, _ k: Int, _ exponent: Double, _ logPower: Int) {
        let result = RecurrenceGrowthReader.solve(a: a, b: b, d: d, k: k)
        #expect(abs(result.exponent - exponent) < 1e-9, "exponent for a = \(a), b = \(b), d = \(d), k = \(k)")
        #expect(result.logPower == logPower, "log power for a = \(a), b = \(b), d = \(d), k = \(k)")
    }

    @Test("The module's recurrences", arguments: [
        (1, 2, 0, 0, 0.0, 1),                     // binary search, fast power: Θ(log n)
        (2, 2, 0, 0, 1.0, 0),                     // four-number summary: Θ(n)
        (2, 2, 1, 0, 1.0, 1),                     // merge sort: Θ(n log n)
        (2, 2, 1, 1, 1.0, 2),                     // closest pair, strip re-sorted: Θ(n log² n)
        (2, 2, 2, 0, 2.0, 0),                     // quadratic combine: Θ(n²)
        (4, 2, 1, 0, 2.0, 0),                     // four products: Θ(n²)
        (3, 2, 1, 0, log2(3.0), 0),               // Karatsuba
        (8, 2, 2, 0, 3.0, 0),                     // eight block products: Θ(n³)
        (7, 2, 2, 0, log2(7.0), 0),               // Strassen
        (1, 2, 1, 0, 1.0, 0),                     // quickselect with ideal halving: Θ(n)
        (3, 3, 1, 0, 1.0, 1),
        (9, 3, 2, 3, 2.0, 4),
        (1, 5, 3, 2, 3.0, 2),
    ] as [(Int, Int, Int, Int, Double, Int)])
    func examples(a: Int, b: Int, d: Int, k: Int, exponent: Double, logPower: Int) {
        check(a, b, d, k, exponent, logPower)
    }

    @Test("Exact ties that floating-point logarithms get wrong")
    func floatingPointTraps() {
        // log(1000) / log(10) and log(243) / log(3) both come out just below a whole number
        check(1_000, 10, 3, 0, 3.0, 1)
        check(243, 3, 5, 0, 5.0, 1)
        check(1_000_000_000_000_000_000, 10, 18, 2, 18.0, 3)
        check(1_000_000_000_000_000_000, 1_000_000_000, 2, 0, 2.0, 1)
        // One more or one less than b^d is not a tie
        check(1_000_000_000_000_000_001, 10, 18, 0, 18.0, 0)
        check(999_999_999_999_999_999, 10, 18, 4, 18.0, 4)
    }

    @Test("Powers too big for an Int")
    func noOverflow() {
        check(2, 2, 63, 0, 63.0, 0)
        check(5, 3, 100, 1, 100.0, 1)
        check(1_000_000_000_000_000_000, 1_000_000_000_000_000_000, 2, 0, 2.0, 0)
        check(Int.max, 2, 62, 0, log2(Double(Int.max)), 0)
    }

    @Test("Matches an exact comparison on 1,000 random recurrences")
    func randomSmall() {
        var random = GrowthRandom(seed: 1_980)
        for _ in 0..<1_000 {
            let a = Int.random(in: 1...300, using: &random)
            let b = Int.random(in: 2...12, using: &random)
            let d = Int.random(in: 0...6, using: &random)
            let k = Int.random(in: 0...3, using: &random)
            var power = 1
            var overflow = false
            for _ in 0..<d {
                let (next, didOverflow) = power.multipliedReportingOverflow(by: b)
                overflow = overflow || didOverflow
                power = next
            }
            if overflow || power > a {
                check(a, b, d, k, Double(d), k)
            } else if power == a {
                check(a, b, d, k, Double(d), k + 1)
            } else {
                check(a, b, d, k, log(Double(a)) / log(Double(b)), 0)
            }
        }
    }
}
