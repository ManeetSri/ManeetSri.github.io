import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct HopsRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct FewestHopsAcrossTests {
    /// Breadth-first search over the stones: each stone is queued once, at its fewest-hops distance.
    /// `next` is the first stone not yet queued, so no stone is looked at twice.
    private func reference(_ steps: [Int]) -> Int {
        let n = steps.count
        var distance = Array(repeating: -1, count: n)
        distance[0] = 0
        var queue = [0]
        var head = 0
        var next = 1
        while head < queue.count {
            let stone = queue[head]
            head += 1
            let reach = min(stone + steps[stone], n - 1)
            while next <= reach {
                distance[next] = distance[stone] + 1
                queue.append(next)
                next += 1
            }
        }
        return distance[n - 1]
    }

    @Test("Examples and small cases", arguments: [
        ([2, 3, 1, 1, 4, 2, 1, 3, 1], 3),
        ([1, 1, 1], 2),
        ([5], 0),
        ([1, 0, 4], -1),
        ([0], 0),
        ([0, 1], -1),
        ([3, 0, 0, 1], 1),
        ([1, 2, 0, 1], 2),
        ([4, 1, 1, 1, 1], 1),
        ([1, 1, 0, 1], -1),
        ([2, 0, 2, 0, 1], 2),
        ([1, 4, 0, 0, 0, 0], 2),
        ([3, 2, 1, 0, 4], -1),
    ] as [([Int], Int)])
    func examples(steps: [Int], expected: Int) {
        #expect(FewestHopsAcross.fewestHops(steps) == expected)
    }

    @Test("Matches breadth-first search on 1,000 small random rivers")
    func randomSmall() {
        var random = HopsRandom(seed: 50)
        for _ in 0..<1_000 {
            let steps = (0..<Int.random(in: 1...12, using: &random)).map { _ in Int.random(in: 0...4, using: &random) }
            #expect(FewestHopsAcross.fewestHops(steps) == reference(steps), "steps \(steps)")
        }
    }

    @Test("100,000 stones with short hops, crossable and not")
    func largeShortHops() {
        var random = HopsRandom(seed: 2_026)
        let crossable = (0..<100_000).map { _ in Int.random(in: 1...10, using: &random) }
        #expect(FewestHopsAcross.fewestHops(crossable) == reference(crossable))
        let blocked = (0..<100_000).map { _ in Int.random(in: 0...10, using: &random) }
        #expect(FewestHopsAcross.fewestHops(blocked) == reference(blocked))
        let ones = Array(repeating: 1, count: 100_000)
        #expect(FewestHopsAcross.fewestHops(ones) == 99_999)
    }

    @Test("100,000 stones with very long hops")
    func largeLongHops() {
        // Every stone can reach the far bank, so trying every possible hop would be billions of steps
        let n = 100_000
        let toTheEnd = (0..<n).map { n - $0 }
        #expect(FewestHopsAcross.fewestHops(toTheEnd) == 1)

        var random = HopsRandom(seed: 7)
        let long = (0..<n).map { _ in Int.random(in: 0...20_000, using: &random) }
        #expect(FewestHopsAcross.fewestHops(long) == reference(long))

        // A wall of dead ends just past the reach of the first stones
        var wall = Array(repeating: 1, count: n)
        wall[0] = 1_000
        for i in 1...1_000 { wall[i] = 1_000 - i }
        #expect(FewestHopsAcross.fewestHops(wall) == -1)
    }
}
