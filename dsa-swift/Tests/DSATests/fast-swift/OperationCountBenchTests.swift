import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BenchRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct OperationCountBenchTests {
    /// Runs `measure` on a scripted list of (operations, result) pairs, and counts the calls
    private func scripted(_ script: [(Int, Int)], warmUp: Int, samples: Int) -> (OperationCountBench.Measurement, Int) {
        var calls = 0
        let measurement = OperationCountBench.measure(warmUp: warmUp, samples: samples) {
            let step = script[min(calls, script.count - 1)]
            calls += 1
            return (operations: step.0, result: step.1)
        }
        return (measurement, calls)
    }

    @Test("The measure example: warm-up ignored, median robust, every result in the checksum")
    func measureExample() {
        let script = [(900, 1), (800, 2), (50, 3), (40, 4), (700, 5), (45, 6), (42, 7)]
        let (measurement, calls) = scripted(script, warmUp: 2, samples: 5)
        #expect(calls == 7)
        #expect(measurement == OperationCountBench.Measurement(median: 45, fewest: 40, checksum: 28))
    }

    @Test("No warm-up, a single sample, and results that wrap around")
    func measureEdges() {
        let (single, calls) = scripted([(17, -5)], warmUp: 0, samples: 1)
        #expect(calls == 1)
        #expect(single == OperationCountBench.Measurement(median: 17, fewest: 17, checksum: -5))
        let script = [(1, Int.max), (5, Int.max), (3, 2), (4, Int.min), (2, 0)]
        let (wrapped, _) = scripted(script, warmUp: 1, samples: 4)
        #expect(wrapped.median == 4)              // samples 5, 3, 4, 2 sort to 2, 3, 4, 5: index 2
        #expect(wrapped.fewest == 2)
        #expect(wrapped.checksum == Int.max &+ Int.max &+ 2 &+ Int.min &+ 0)
    }

    @Test("Warm-up calls come first and never count")
    func warmUpFirst() {
        // The first 10 calls are expensive (cold caches, one-off set-up); after that, steady
        var calls = 0
        let measurement = OperationCountBench.measure(warmUp: 10, samples: 21) {
            calls += 1
            return (operations: calls <= 10 ? 1_000_000 : 100 + calls % 7, result: calls)
        }
        #expect(calls == 31)
        #expect(measurement.fewest == 100)
        #expect(measurement.median < 1_000)
        #expect(measurement.checksum == (1...31).reduce(0, +))
    }

    @Test("Verdicts", arguments: [
        ([124, 121, 126, 122, 123], [119, 125, 120, 122, 121], OperationCountBench.Verdict.noDifference),
        ([100, 102, 98, 101, 99], [60, 61, 59, 62, 60], .faster),
        ([10, 10, 10], [12, 12, 12], .slower),
        ([10, 10, 10], [10, 10, 10], .noDifference),
        ([5], [6], .slower),
        ([50, 10, 90, 30, 70], [45, 5, 85, 25, 65], .noDifference),
        ([1_000, 1_010, 990, 1_005, 995, 1_002, 998], [1_100, 1_090, 1_110, 1_095, 1_105, 1_099, 1_101], .slower),
    ])
    func verdicts(before: [Int], after: [Int], expected: OperationCountBench.Verdict) {
        #expect(OperationCountBench.verdict(before: before, after: after) == expected)
    }

    @Test("One wild sample doesn't change a verdict")
    func verdictOutlier() {
        let before = [200, 201, 199, 202, 198, 200, 201]
        let after = [150, 151, 149, 9_999, 150, 152, 148]     // one interrupted run
        #expect(OperationCountBench.verdict(before: before, after: after) == .faster)
    }

    @Test("Growth exponents")
    func growth() {
        #expect(abs(OperationCountBench.growthExponent(costs: [1_900, 7_800, 31_500, 125_000]) - 2.013_78) < 0.000_1)
        #expect(OperationCountBench.growthExponent(costs: [100, 200, 400, 5_000, 1_600, 3_200]) == 1.0)
        #expect(OperationCountBench.growthExponent(costs: [1_000, 2_000, 4_000, 8_000]) == 1.0)
        #expect(OperationCountBench.growthExponent(costs: [7, 7, 7]) == 0.0)
        #expect(OperationCountBench.growthExponent(costs: [3, 24]) == 3.0)
        // Two ratios: the mean of 2 and 8 is 5
        #expect(abs(OperationCountBench.growthExponent(costs: [1, 2, 16]) - log2(5.0)) < 1e-12)
        // n log n grows a little faster than linear
        let nLogN = (10...15).map { k in (1 << k) * k }
        let exponent = OperationCountBench.growthExponent(costs: nLogN)
        #expect(exponent > 1.05 && exponent < 1.15)
    }

    @Test("Counting real work: a scan against binary search, and quadratic against linear")
    func realWork() {
        var random = BenchRandom(seed: 68)
        let sorted = (0..<4_096).map { $0 * 2 }
        var linearCounts: [Int] = []
        var binaryCounts: [Int] = []
        func target() -> Int { Int.random(in: 0..<8_192, using: &random) }
        let linear = OperationCountBench.measure(warmUp: 3, samples: 31) {
            let t = target()
            var steps = 0
            for value in sorted {
                steps += 1
                if value >= t { break }
            }
            linearCounts.append(steps)
            return (operations: steps, result: t)
        }
        let binary = OperationCountBench.measure(warmUp: 3, samples: 31) {
            let t = target()
            var low = 0
            var high = sorted.count
            var steps = 0
            while low < high {
                steps += 1
                let mid = (low + high) / 2
                if sorted[mid] < t { low = mid + 1 } else { high = mid }
            }
            binaryCounts.append(steps)
            return (operations: steps, result: t)
        }
        #expect(linearCounts.count == 34 && binaryCounts.count == 34, "measure should call the work 3 + 31 times")
        guard linearCounts.count == 34, binaryCounts.count == 34 else { return }
        #expect(linear.median == Array(linearCounts.suffix(31)).sorted()[15])
        #expect(binary.median == 12 || binary.median == 13)
        #expect(OperationCountBench.verdict(before: Array(linearCounts.suffix(31)), after: Array(binaryCounts.suffix(31))) == .faster)
        // Doubling experiment: pairs compared by a nested loop grow 4× per doubling
        let pairs = [100, 200, 400, 800, 1_600].map { n in n * (n - 1) / 2 }
        #expect(abs(OperationCountBench.growthExponent(costs: pairs) - 2) < 0.01)
    }
}
