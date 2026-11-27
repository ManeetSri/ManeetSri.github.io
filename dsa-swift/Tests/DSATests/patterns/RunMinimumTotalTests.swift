import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TripRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RunMinimumTotalTests {
    /// Every trip, with a running minimum
    private func brute(_ rates: [Int]) -> Int {
        var sum = 0
        for first in rates.indices {
            var cheapest = Int.max
            for last in first..<rates.count {
                cheapest = min(cheapest, rates[last])
                sum += cheapest
            }
        }
        return sum
    }

    @Test("The examples", arguments: [
        ([3, 1, 2, 4], 17),
        ([1, 2, 3], 10),
        ([2, 2, 2], 12),
        ([5], 5),
        ([], 0),
    ])
    func examples(rates: [Int], expected: Int) {
        #expect(RunMinimumTotal.total(rates) == expected)
    }

    @Test("Falling rates, valleys and repeated values")
    func shapes() {
        #expect(RunMinimumTotal.total([3, 2, 1]) == 10)
        #expect(RunMinimumTotal.total([5, 1, 5]) == 5 + 1 + 5 + 1 + 1 + 1)
        #expect(RunMinimumTotal.total([1, 3, 1, 3, 1]) == brute([1, 3, 1, 3, 1]))
        #expect(RunMinimumTotal.total([4, 4, 1, 4, 4]) == brute([4, 4, 1, 4, 4]))
    }

    @Test("Random rates, with many ties, match listing every trip", arguments: [1, 2, 3])
    func matchesBrute(seed: UInt64) {
        var random = TripRandom(seed: seed)
        for trial in 0..<300 {
            let n = Int.random(in: 0...40, using: &random)
            let top = trial.isMultiple(of: 2) ? 3 : 10_000
            let rates = (0..<n).map { _ in Int.random(in: 1...top, using: &random) }
            let actual = RunMinimumTotal.total(rates)
            #expect(actual == brute(rates), "\(rates)")
            if actual != brute(rates) { return }
        }
    }

    @Test("100,000 days")
    func large() {
        let n = 100_000
        // Every rate equal: each of the n(n + 1) / 2 trips costs 10,000
        #expect(RunMinimumTotal.total(Array(repeating: 10_000, count: n)) == 10_000 * n * (n + 1) / 2)
        // Rising rates 1, 2, …, n: trips starting at day i have minimum i + 1, and there are n − i of them
        let rising = Array(1...n)
        let expected = (0..<n).reduce(0) { $0 + ($1 + 1) * (n - $1) }
        #expect(RunMinimumTotal.total(rising) == expected)
        // Random rates, checked on a prefix the brute force can handle
        var random = TripRandom(seed: 59)
        let rates = (0..<n).map { _ in Int.random(in: 1...10_000, using: &random) }
        let prefix = Array(rates.prefix(2_000))
        #expect(RunMinimumTotal.total(prefix) == brute(prefix))
        #expect(RunMinimumTotal.total(rates) >= RunMinimumTotal.total(prefix))
    }
}
