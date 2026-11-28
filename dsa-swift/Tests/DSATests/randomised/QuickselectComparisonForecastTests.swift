import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A seeded generator (SplitMix64), so every simulated run makes the same "random" choices
private struct ForecastRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@Suite struct QuickselectComparisonForecastTests {
    private func close(_ actual: Double, _ expected: Double, _ relative: Double = 1e-9) -> Bool {
        abs(actual - expected) <= relative * max(1, abs(expected))
    }

    /// The pair formula, summed over every pair
    private func pairSum(_ n: Int, _ t: Int) -> Double {
        var total = 0.0
        for a in 0..<n {
            for b in (a + 1)..<max(a + 1, n) {
                total += 2.0 / Double(max(b, t) - min(a, t) + 1)
            }
        }
        return total
    }

    private func harmonic(_ m: Int) -> Double {
        var total = 0.0
        for i in stride(from: 1, through: m, by: 1) {
            total += 1.0 / Double(i)
        }
        return total
    }

    /// One run of the quickselect being forecast: (comparisons, partitions)
    private func run(_ n: Int, _ t: Int, _ random: inout ForecastRandom) -> (Int, Int) {
        var items = Array(0..<n).shuffled(using: &random)
        var low = 0
        var high = n - 1
        var comparisons = 0
        var partitions = 0
        while true {
            partitions += 1
            items.swapAt(Int.random(in: low...high, using: &random), high)
            let pivot = items[high]
            var boundary = low
            for j in low..<high {
                comparisons += 1
                if items[j] < pivot {
                    items.swapAt(boundary, j)
                    boundary += 1
                }
            }
            items.swapAt(boundary, high)
            if boundary == t { return (comparisons, partitions) }
            if t < boundary { high = boundary - 1 } else { low = boundary + 1 }
        }
    }

    @Test("The examples")
    func examples() {
        #expect(close(QuickselectComparisonForecast.expectedComparisons(count: 3, targetRank: 1), 8.0 / 3.0))
        #expect(close(QuickselectComparisonForecast.expectedComparisons(count: 2, targetRank: 0), 1))
        #expect(close(QuickselectComparisonForecast.expectedComparisons(count: 2, targetRank: 1), 1))
        #expect(QuickselectComparisonForecast.expectedComparisons(count: 1, targetRank: 0) == 0)
        #expect(abs(QuickselectComparisonForecast.expectedComparisons(count: 1_000, targetRank: 0) - 1_985.029) < 0.001)
        #expect(abs(QuickselectComparisonForecast.expectedComparisons(count: 1_000, targetRank: 500) - 3_336.330) < 0.001)
        #expect(close(QuickselectComparisonForecast.expectedPartitions(count: 3, targetRank: 1), 2))
        #expect(close(QuickselectComparisonForecast.expectedPartitions(count: 4, targetRank: 0), 25.0 / 12.0))
        #expect(close(QuickselectComparisonForecast.expectedPartitions(count: 1, targetRank: 0), 1))
    }

    @Test("Every target for small n matches the sum over all pairs")
    func matchesPairSum() {
        for n in 1...45 {
            for t in 0..<n {
                let expected = pairSum(n, t)
                let actual = QuickselectComparisonForecast.expectedComparisons(count: n, targetRank: t)
                if !close(actual, expected) {
                    Issue.record("n = \(n), t = \(t): expected \(expected), got \(actual)")
                    return
                }
                let partitions = (0..<n).reduce(0.0) { $0 + 1.0 / Double(abs($1 - t) + 1) }
                #expect(close(QuickselectComparisonForecast.expectedPartitions(count: n, targetRank: t), partitions), "partitions, n = \(n), t = \(t)")
            }
        }
    }

    @Test("The smallest costs 2(n − H(n)), and targets are symmetric")
    func smallestAndSymmetry() {
        for n in [5, 64, 999, 10_000] {
            let smallest = QuickselectComparisonForecast.expectedComparisons(count: n, targetRank: 0)
            #expect(close(smallest, 2 * (Double(n) - harmonic(n))), "n = \(n)")
            let largest = QuickselectComparisonForecast.expectedComparisons(count: n, targetRank: n - 1)
            #expect(close(smallest, largest), "n = \(n)")
            let left = QuickselectComparisonForecast.expectedComparisons(count: n, targetRank: n / 3)
            let right = QuickselectComparisonForecast.expectedComparisons(count: n, targetRank: n - 1 - n / 3)
            #expect(close(left, right), "n = \(n)")
        }
    }

    @Test("Averages of real seeded runs agree with the forecast", arguments: [(60, 30), (200, 0), (200, 150)])
    func simulation(n: Int, t: Int) {
        var random = ForecastRandom(seed: UInt64(n * 1_000 + t))
        let runs = 3_000
        var comparisons = 0
        var partitions = 0
        for _ in 0..<runs {
            let (c, p) = run(n, t, &random)
            comparisons += c
            partitions += p
        }
        let forecast = QuickselectComparisonForecast.expectedComparisons(count: n, targetRank: t)
        let rounds = QuickselectComparisonForecast.expectedPartitions(count: n, targetRank: t)
        #expect(abs(Double(comparisons) / Double(runs) - forecast) < 0.03 * forecast, "comparisons")
        #expect(abs(Double(partitions) / Double(runs) - rounds) < 0.05 * rounds, "partitions")
    }

    @Test("A million values, checked against Knuth's closed form")
    func large() {
        let n = 1_000_000
        let hn = harmonic(n)
        for t in [0, 1, 367_879, 500_000, 999_999] {
            let k = t + 1
            let knuth = 2 * (Double(n + 1) * hn - Double(n + 3 - k) * harmonic(n + 1 - k) - Double(k + 2) * harmonic(k) + Double(n) + 3)
            #expect(close(QuickselectComparisonForecast.expectedComparisons(count: n, targetRank: t), knuth), "t = \(t)")
        }
        let median = QuickselectComparisonForecast.expectedComparisons(count: n, targetRank: n / 2)
        #expect(median > 3.38 * Double(n) && median < 3.39 * Double(n), "the median costs about 2n(1 + ln 2)")
        let rounds = QuickselectComparisonForecast.expectedPartitions(count: n, targetRank: n / 2)
        #expect(close(rounds, harmonic(n / 2 + 1) + harmonic(n / 2) - 1))
    }
}
