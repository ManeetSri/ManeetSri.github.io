import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CrateRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// An independent fast reference. Heights only ever rise, and a crate raises its whole range to at
/// least its top, so "raise to at least h" tags commute and never need pushing down: each node keeps
/// the largest height raised over all of it, and the largest height anywhere below it.
private struct RaisedHeights {
    private var raisedWhole: [Int]
    private var highestBelow: [Int]
    private let count: Int

    init(count: Int) {
        self.count = count
        raisedWhole = Array(repeating: 0, count: 4 * count)
        highestBelow = Array(repeating: 0, count: 4 * count)
    }

    func highest(_ left: Int, _ right: Int, _ node: Int = 1, _ low: Int = 0, _ high: Int? = nil) -> Int {
        let high = high ?? count - 1
        if right < low || high < left { return 0 }
        if left <= low && high <= right { return highestBelow[node] }
        let mid = (low + high) / 2
        return max(raisedWhole[node], highest(left, right, 2 * node, low, mid), highest(left, right, 2 * node + 1, mid + 1, high))
    }

    mutating func raise(_ value: Int, _ left: Int, _ right: Int, _ node: Int = 1, _ low: Int = 0, _ high: Int? = nil) {
        let high = high ?? count - 1
        if right < low || high < left { return }
        highestBelow[node] = max(highestBelow[node], value)
        if left <= low && high <= right {
            raisedWhole[node] = max(raisedWhole[node], value)
            return
        }
        let mid = (low + high) / 2
        raise(value, left, right, 2 * node, low, mid)
        raise(value, left, right, 2 * node + 1, mid + 1, high)
    }
}

@Suite struct StackingCratesTests {
    /// Each crate lands on the highest earlier crate it overlaps. O(n²), but clearly right.
    private func reference(_ crates: [[Int]]) -> [Int] {
        var tops: [Int] = []
        var tallest = 0
        var result: [Int] = []
        for (i, crate) in crates.enumerated() {
            var base = 0
            for j in 0..<i where crates[j][0] < crate[0] + crate[1] && crate[0] < crates[j][0] + crates[j][1] {
                base = max(base, tops[j])
            }
            tops.append(base + crate[1])
            tallest = max(tallest, base + crate[1])
            result.append(tallest)
        }
        return result
    }

    /// The fast reference: compress the edges, then raise ranges.
    private func fastReference(_ crates: [[Int]]) -> [Int] {
        let edges = Array(Set(crates.flatMap { [$0[0], $0[0] + $0[1]] })).sorted()
        var position: [Int: Int] = [:]
        for (rank, edge) in edges.enumerated() { position[edge] = rank }
        var heights = RaisedHeights(count: max(1, edges.count - 1))
        var tallest = 0
        return crates.map { crate in
            let first = position[crate[0]]!, last = position[crate[0] + crate[1]]! - 1
            let top = heights.highest(first, last) + crate[1]
            heights.raise(top, first, last)
            tallest = max(tallest, top)
            return tallest
        }
    }

    @Test("Examples and small cases", arguments: [
        ([[1, 3], [2, 2], [7, 4], [4, 1], [3, 5]], [3, 5, 5, 5, 10]),
        ([[0, 2], [2, 3]], [2, 3]),
        ([[5, 4]], [4]),
        ([[0, 10], [0, 10], [0, 10]], [10, 20, 30]),
        ([[0, 1], [1, 1], [2, 1], [0, 3]], [1, 1, 1, 4]),
        ([[3, 2], [0, 4], [5, 1], [4, 2]], [2, 6, 6, 6]),
        ([[1_000_000_000, 1_000_000], [999_999_999, 2]], [1_000_000, 1_000_002]),
        ([], []),
    ] as [([[Int]], [Int])])
    func examples(crates: [[Int]], expected: [Int]) {
        #expect(StackingCrates.tallestAfterEachDrop(crates) == expected)
    }

    @Test("Matches the O(n²) simulation on 400 small random drops")
    func randomSmall() {
        var random = CrateRandom(seed: 63)
        for _ in 0..<400 {
            let crates = (0..<Int.random(in: 1...15, using: &random)).map { _ in
                [Int.random(in: 0...20, using: &random), Int.random(in: 1...6, using: &random)]
            }
            #expect(StackingCrates.tallestAfterEachDrop(crates) == reference(crates))
        }
    }

    @Test("A tall tower of identical crates, built 100,000 high")
    func tower() {
        let crates = Array(repeating: [123_456_789, 1_000_000], count: 100_000)
        let result = StackingCrates.tallestAfterEachDrop(crates)
        #expect(result.count == 100_000)
        #expect(result.first == 1_000_000)
        #expect(result.last == 100_000 * 1_000_000)
    }

    @Test("100,000 crates on a crowded stretch of floor")
    func large() {
        // The O(n²) simulation would compare about 5 × 10⁹ pairs of crates
        var random = CrateRandom(seed: 2_029)
        let crates = (0..<100_000).map { _ in
            [Int.random(in: 0...10_000_000, using: &random), Int.random(in: 1...100_000, using: &random)]
        }
        let expected = fastReference(crates)
        #expect(expected.last! > 1_000_000)               // the crates really do pile up
        #expect(StackingCrates.tallestAfterEachDrop(crates) == expected)
    }
}
