import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RangeKthRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PersistentRangeKthTests {
    @Test("The examples")
    func examples() {
        let finder = PersistentRangeKth.Finder([5, 1, 7, 3, 8, 2, 6, 4])
        #expect(finder.kthSmallest(1, from: 1, through: 6) == 1)
        #expect(finder.kthSmallest(3, from: 1, through: 6) == 3)
        #expect(finder.kthSmallest(6, from: 1, through: 6) == 8)
        #expect(finder.kthSmallest(1, from: 4, through: 4) == 8)
        #expect(finder.kthSmallest(4, from: 0, through: 7) == 4)
        let repeated = PersistentRangeKth.Finder([4, 4, 1, 4, 9, 1])
        #expect(repeated.kthSmallest(3, from: 0, through: 5) == 4)
        #expect(repeated.kthSmallest(2, from: 3, through: 5) == 4)
        #expect(repeated.kthSmallest(1, from: 0, through: 5) == 1)
        #expect(repeated.kthSmallest(6, from: 0, through: 5) == 9)
    }

    @Test("A single price, and every price the same")
    func tiny() {
        let one = PersistentRangeKth.Finder([-7])
        #expect(one.kthSmallest(1, from: 0, through: 0) == -7)
        let same = PersistentRangeKth.Finder(Array(repeating: 3, count: 50))
        #expect(same.kthSmallest(1, from: 0, through: 49) == 3)
        #expect(same.kthSmallest(25, from: 10, through: 40) == 3)
    }

    @Test("Every query on small arrays matches sorting the range")
    func everyQuery() {
        var random = RangeKthRandom(seed: 60)
        for trial in 0..<30 {
            let n = Int.random(in: 1...14, using: &random)
            let spread = trial.isMultiple(of: 3) ? 3 : 1_000
            let prices = (0..<n).map { _ in Int.random(in: -spread...spread, using: &random) }
            let finder = PersistentRangeKth.Finder(prices)
            for left in 0..<n {
                for right in left..<n {
                    let sorted = prices[left...right].sorted()
                    for k in 1...sorted.count where finder.kthSmallest(k, from: left, through: right) != sorted[k - 1] {
                        Issue.record("prices \(prices): kthSmallest(\(k), from: \(left), through: \(right)) should be \(sorted[k - 1])")
                        return
                    }
                }
            }
        }
    }

    @Test("Extreme prices")
    func extremes() {
        let prices = [1_000_000_000, -1_000_000_000, 0, 1_000_000_000, -1_000_000_000]
        let finder = PersistentRangeKth.Finder(prices)
        #expect(finder.kthSmallest(1, from: 0, through: 4) == -1_000_000_000)
        #expect(finder.kthSmallest(3, from: 0, through: 4) == 0)
        #expect(finder.kthSmallest(5, from: 0, through: 4) == 1_000_000_000)
        #expect(finder.kthSmallest(2, from: 2, through: 3) == 1_000_000_000)
    }

    @Test("100,000 queries about 100,000 prices")
    func large() {
        var random = RangeKthRandom(seed: 100_000)
        let n = 100_000
        let prices = (0..<n).map { _ in Int.random(in: -1_000_000_000...1_000_000_000, using: &random) }
        let finder = PersistentRangeKth.Finder(prices)
        // The whole array: the answers are the sorted prices themselves
        let sorted = prices.sorted()
        for k in [1, 2, 500, 50_000, 99_999, 100_000] {
            #expect(finder.kthSmallest(k, from: 0, through: n - 1) == sorted[k - 1], "k = \(k) over everything")
        }
        // Many long ranges; check a sample of them by sorting
        var checksum = 0
        for query in 0..<100_000 {
            let left = Int.random(in: 0..<(n / 2), using: &random)
            let right = Int.random(in: left..<n, using: &random)
            let k = Int.random(in: 1...(right - left + 1), using: &random)
            let answer = finder.kthSmallest(k, from: left, through: right)
            checksum &+= answer
            if query % 20_000 == 0 {
                #expect(answer == prices[left...right].sorted()[k - 1], "query \(query)")
            }
        }
        #expect(checksum != 0)
    }
}
