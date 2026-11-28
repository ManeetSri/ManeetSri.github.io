import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A seeded generator (SplitMix64), so every run makes the same "random" choices
private struct PickRandom: RandomNumberGenerator {
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

@Suite struct WeightedServerPickTests {
    /// Makes `picks` picks and counts how often each server is chosen. Out-of-range picks are counted
    /// in `invalid` rather than crashing.
    private func counts(_ weights: [Int], picks: Int, seed: UInt64) -> (counts: [Int], invalid: Int) {
        let picker = WeightedServerPick.Picker(weights: weights)
        var random = PickRandom(seed: seed)
        var counts = [Int](repeating: 0, count: weights.count)
        var invalid = 0
        for _ in 0..<picks {
            let server = picker.pick(using: &random)
            if counts.indices.contains(server) { counts[server] += 1 } else { invalid += 1 }
        }
        return (counts, invalid)
    }

    @Test("Picks follow the weights [1, 2, 3, 4]")
    func proportional() {
        let (counts, invalid) = counts([1, 2, 3, 4], picks: 100_000, seed: 67)
        #expect(invalid == 0)
        for (server, expected) in [10_000, 20_000, 30_000, 40_000].enumerated() {
            #expect(abs(counts[server] - expected) < 800, "server \(server) was picked \(counts[server]) times; expected about \(expected)")
        }
    }

    @Test("The lesson's weights [5, 1, 3, 1]")
    func lessonWeights() {
        let (counts, invalid) = counts([5, 1, 3, 1], picks: 50_000, seed: 8)
        #expect(invalid == 0)
        for (server, expected) in [25_000, 5_000, 15_000, 5_000].enumerated() {
            #expect(abs(counts[server] - expected) < 600, "server \(server) was picked \(counts[server]) times; expected about \(expected)")
        }
    }

    @Test("Servers with weight 0 are never picked", arguments: [
        [0, 7, 0],
        [0, 0, 0, 1],
        [3, 0, 0, 3],
        [1, 0, 1, 0, 1, 0],
        [0, 1_000_000_000],
    ])
    func zeroWeights(weights: [Int]) {
        let (counts, invalid) = counts(weights, picks: 3_000, seed: UInt64(weights.count))
        #expect(invalid == 0)
        for (server, weight) in weights.enumerated() where weight == 0 {
            #expect(counts[server] == 0, "server \(server) has weight 0 but was picked \(counts[server]) times")
        }
        #expect(counts.reduce(0, +) == 3_000)
    }

    @Test("A single server is always picked")
    func single() {
        let (counts, invalid) = counts([4], picks: 100, seed: 1)
        #expect(invalid == 0)
        #expect(counts == [100])
    }

    @Test("Equal weights pick evenly, including the first and last servers")
    func even() {
        let (counts, invalid) = counts([1, 1, 1, 1, 1, 1, 1, 1], picks: 80_000, seed: 2_026)
        #expect(invalid == 0)
        for (server, count) in counts.enumerated() {
            #expect(abs(count - 10_000) < 500, "server \(server) was picked \(count) times; expected about 10,000")
        }
    }

    @Test("Huge weights don't overflow, and tiny ones still get their share")
    func hugeWeights() {
        let weights = [1_000_000_000, 1_000_000_000, 1, 1_000_000_000]
        let (counts, invalid) = counts(weights, picks: 30_000, seed: 3)
        #expect(invalid == 0)
        #expect(counts[2] <= 2, "a weight of 1 in three billion should almost never be picked")
        for server in [0, 1, 3] {
            #expect(abs(counts[server] - 10_000) < 500)
        }
    }

    @Test("The same seed gives the same picks")
    func reproducible() {
        let picker = WeightedServerPick.Picker(weights: [3, 1, 4, 1, 5, 9, 2, 6])
        var first = PickRandom(seed: 42)
        var second = PickRandom(seed: 42)
        let a = (0..<50).map { _ in picker.pick(using: &first) }
        let b = (0..<50).map { _ in picker.pick(using: &second) }
        #expect(a == b)
        #expect(Set(a).count > 3, "50 picks from 8 servers should reach more than 3 of them")
    }

    @Test("100,000 picks from 100,000 servers")
    func large() {
        // Even servers have weight 0, odd ones have weight 1 in the first half and 3 in the second half,
        // so the second half should get three quarters of the picks
        let n = 100_000
        let weights = (0..<n).map { $0 % 2 == 0 ? 0 : ($0 < n / 2 ? 1 : 3) }
        let (counts, invalid) = counts(weights, picks: 100_000, seed: 7)
        #expect(invalid == 0)
        let evenPicks = stride(from: 0, to: n, by: 2).reduce(0) { $0 + counts[$1] }
        #expect(evenPicks == 0)
        let secondHalf = counts[(n / 2)...].reduce(0, +)
        #expect(abs(secondHalf - 75_000) < 800, "the heavier half got \(secondHalf) picks; expected about 75,000")
    }
}
