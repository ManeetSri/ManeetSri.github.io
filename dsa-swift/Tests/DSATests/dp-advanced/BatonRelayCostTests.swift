import DSAKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RelayRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BatonRelayCostTests {
    /// The direct DP: scan the whole window for every checkpoint. O(n · window).
    private func direct(_ fees: [Int], _ shortest: Int, _ longest: Int) -> Int {
        let n = fees.count
        var cost = [Int?](repeating: nil, count: n)
        cost[0] = fees[0]
        for i in 1..<max(n, 1) {
            for j in max(0, i - longest)...max(0, i - shortest) where j <= i - shortest {
                if let before = cost[j] {
                    cost[i] = min(cost[i] ?? Int.max, before + fees[i])
                }
            }
        }
        return cost[n - 1] ?? -1
    }

    /// A different fast method: a min-heap of (cost, index), discarding indexes that fall out of reach
    private func withHeap(_ fees: [Int], _ shortest: Int, _ longest: Int) -> Int {
        let n = fees.count
        var cost = [Int](repeating: -1, count: n)
        cost[0] = fees[0]
        var heap = Heap<(cost: Int, index: Int)>(areInIncreasingOrder: { $0.cost < $1.cost })
        for i in 1..<max(n, 1) {
            let joining = i - shortest
            if joining >= 0 && cost[joining] >= 0 { heap.insert((cost[joining], joining)) }
            while let top = heap.peek(), top.index < i - longest { _ = heap.pop() }
            if let top = heap.peek() { cost[i] = fees[i] + top.cost }
        }
        return cost[n - 1]
    }

    @Test("Examples and small cases", arguments: [
        ([2, 7, 3, 9, 1, 8, 8, 4, 6, 2], 2, 3, 12),
        ([2, 7, 3, 9, 1, 8, 8, 4, 6, 2], 1, 3, 12),
        ([5], 1, 1, 5),
        ([5, 0, 0, 1], 2, 2, -1),
        ([5, 0, 0, 1], 3, 3, 6),
        ([4, 1, 1, 1, 1], 1, 1, 8),
        ([3, 100, 100, 1], 1, 4, 4),
    ] as [([Int], Int, Int, Int)])
    func examples(fees: [Int], shortest: Int, longest: Int, expected: Int) {
        #expect(BatonRelayCost.cheapestRelay(fees: fees, shortest: shortest, longest: longest) == expected)
    }

    @Test("Matches the direct DP on 500 small random routes")
    func randomSmall() {
        var random = RelayRandom(seed: 58)
        for _ in 0..<500 {
            let n = Int.random(in: 1...30, using: &random)
            let fees = (0..<n).map { _ in Int.random(in: 0...50, using: &random) }
            let longest = Int.random(in: 1...n, using: &random)
            let shortest = Int.random(in: 1...longest, using: &random)
            #expect(BatonRelayCost.cheapestRelay(fees: fees, shortest: shortest, longest: longest) == direct(fees, shortest, longest))
        }
    }

    @Test("200,000 checkpoints with wide windows")
    func large() {
        var random = RelayRandom(seed: 2_058)
        let n = 200_000
        let fees = (0..<n).map { _ in Int.random(in: 0...1_000_000_000, using: &random) }
        for (shortest, longest) in [(1, 100_000), (1_000, 60_000), (3, 3), (40_000, 50_000)] {
            #expect(BatonRelayCost.cheapestRelay(fees: fees, shortest: shortest, longest: longest) == withHeap(fees, shortest, longest))
        }
        // Rising fees: the best relay uses as few legs as possible
        let rising = Array(0..<n)
        #expect(BatonRelayCost.cheapestRelay(fees: rising, shortest: 1, longest: n) == n - 1)
    }
}
