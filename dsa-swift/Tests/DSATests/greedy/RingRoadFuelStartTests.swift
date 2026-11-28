import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RingRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RingRoadFuelStartTests {
    /// True if driving once round the ring from `start` never runs the tank below zero
    private func works(_ fuel: [Int], _ cost: [Int], from start: Int) -> Bool {
        var tank = 0
        for step in 0..<fuel.count {
            let station = (start + step) % fuel.count
            tank += fuel[station] - cost[station]
            if tank < 0 { return false }
        }
        return true
    }

    /// Try every start in order: slow, but clearly right
    private func reference(_ fuel: [Int], _ cost: [Int]) -> Int {
        fuel.indices.first { works(fuel, cost, from: $0) } ?? -1
    }

    @Test("Examples and small cases", arguments: [
        ([4, 1, 2, 6, 1], [3, 4, 3, 1, 3], 3),
        ([2, 2], [3, 2], -1),
        ([1, 5, 2, 3], [2, 1, 4, 2], 1),
        ([5], [5], 0),
        ([4], [5], -1),
        ([0, 0, 0], [0, 0, 0], 0),
        ([1, 3], [2, 1], 1),
        ([2, 5, 1, 4, 3], [3, 2, 4, 1, 4], 1),
        ([0, 0, 9], [3, 3, 3], 2),
        ([3, 0, 0], [1, 1, 1], 0),
    ] as [([Int], [Int], Int)])
    func examples(fuel: [Int], cost: [Int], expected: Int) {
        #expect(RingRoadFuelStart.startStation(fuel: fuel, cost: cost) == expected)
    }

    @Test("Matches trying every start on 1,000 small random rings")
    func randomSmall() {
        var random = RingRandom(seed: 50)
        for _ in 0..<1_000 {
            let n = Int.random(in: 1...8, using: &random)
            let fuel = (0..<n).map { _ in Int.random(in: 0...6, using: &random) }
            let cost = (0..<n).map { _ in Int.random(in: 0...6, using: &random) }
            #expect(RingRoadFuelStart.startStation(fuel: fuel, cost: cost) == reference(fuel, cost), "fuel \(fuel), cost \(cost)")
        }
    }

    @Test("100,000 stations with a lap total of exactly 0, then 1 litre short")
    func large() {
        var random = RingRandom(seed: 2_026)
        let n = 100_000
        var fuel = (0..<n).map { _ in Int.random(in: 0...10_000, using: &random) }
        let cost = (0..<n).map { _ in Int.random(in: 0...10_000, using: &random) }
        // Nudge random stations' fuel, within 0...10,000, until the lap total is exactly 0
        var difference = cost.reduce(0, +) - fuel.reduce(0, +)
        while difference != 0 {
            let station = Int.random(in: 0..<n, using: &random)
            let change = difference > 0 ? min(difference, 10_000 - fuel[station]) : -min(-difference, fuel[station])
            fuel[station] += change
            difference -= change
        }
        // With a total of 0, the stations that work are exactly those right after the lowest running
        // total, and the answer is the first of them
        var running = 0
        var lowest = 0
        var expected = 0
        for i in 0..<n {
            running += fuel[i] - cost[i]
            if running < lowest {
                lowest = running
                expected = i + 1
            }
        }
        let answer = RingRoadFuelStart.startStation(fuel: fuel, cost: cost)
        #expect(answer == expected)
        if answer >= 0 && answer < n {
            #expect(works(fuel, cost, from: answer))
        }

        // Take away one litre: now nothing works
        var short = fuel
        if let station = short.firstIndex(where: { $0 > 0 }) {
            short[station] -= 1
            #expect(RingRoadFuelStart.startStation(fuel: short, cost: cost) == -1)
        }
        let none = Array(repeating: 0, count: n)
        #expect(RingRoadFuelStart.startStation(fuel: none, cost: Array(repeating: 1, count: n)) == -1)
        #expect(RingRoadFuelStart.startStation(fuel: none, cost: none) == 0)
    }

    @Test("Only the last station works")
    func lastStation() {
        let n = 100_000
        var fuel = Array(repeating: 0, count: n)
        fuel[n - 1] = n
        let cost = Array(repeating: 1, count: n)
        #expect(RingRoadFuelStart.startStation(fuel: fuel, cost: cost) == n - 1)
    }
}
