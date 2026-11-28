import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SignalRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SignalSpreadTimeTests {
    /// Bellman–Ford: relax every link n - 1 times. Slow, but clearly right.
    private func reference(_ n: Int, _ links: [[Int]], _ source: Int) -> Int {
        var arrival = Array(repeating: Int.max, count: n)
        arrival[source] = 0
        for _ in 0..<max(n - 1, 0) {
            for link in links where arrival[link[0]] != Int.max {
                arrival[link[1]] = min(arrival[link[1]], arrival[link[0]] + link[2])
            }
        }
        return arrival.contains(Int.max) ? -1 : arrival.max()!
    }

    @Test("Examples and small cases", arguments: [
        (4, [[1, 0, 3], [1, 2, 1], [2, 3, 1]], 1, 3),
        (3, [[0, 1, 4], [0, 2, 10], [1, 2, 3]], 0, 7),
        (2, [[0, 1, 7]], 1, -1),
        (1, [], 0, 0),
        (3, [[0, 1, 0], [1, 2, 0]], 0, 0),
        (2, [[0, 1, 9], [0, 1, 4]], 0, 4),
        (2, [[0, 0, 5], [0, 1, 2]], 0, 2),
        (5, [[0, 1, 2], [0, 2, 5], [1, 2, 1], [1, 3, 6], [2, 3, 2], [3, 4, 1], [2, 4, 7]], 0, 6),
        (3, [[0, 1, 1], [1, 0, 1]], 0, -1),
    ] as [(Int, [[Int]], Int, Int)])
    func examples(n: Int, links: [[Int]], source: Int, expected: Int) {
        #expect(SignalSpreadTime.spreadTime(n: n, links: links, source: source) == expected)
    }

    @Test("Matches Bellman–Ford on 400 small random networks")
    func randomSmall() {
        var random = SignalRandom(seed: 44)
        for _ in 0..<400 {
            let n = Int.random(in: 1...8, using: &random)
            let links = (0..<Int.random(in: 0...20, using: &random)).map { _ in
                [Int.random(in: 0..<n, using: &random), Int.random(in: 0..<n, using: &random), Int.random(in: 0...20, using: &random)]
            }
            let source = Int.random(in: 0..<n, using: &random)
            #expect(SignalSpreadTime.spreadTime(n: n, links: links, source: source) == reference(n, links, source))
        }
    }

    @Test("20,000 servers and 100,000 links with a planted answer")
    func large() {
        // Give every server a target arrival time, connect each to an earlier one with exactly the right
        // delay, and make every other link too slow to help. The arrival times are then exactly the
        // targets, so the answer is the largest target.
        var random = SignalRandom(seed: 2_024)
        let n = 20_000
        var target = (0..<n).map { _ in Int.random(in: 1...1_000_000, using: &random) }
        target[0] = 0
        let order = (0..<n).sorted { (target[$0], $0) < (target[$1], $1) }
        var links: [[Int]] = []
        for position in 1..<n {
            let server = order[position]
            let earlier = order[Int.random(in: 0..<position, using: &random)]
            links.append([earlier, server, target[server] - target[earlier]])
        }
        while links.count < 100_000 {
            let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
            links.append([a, b, max(0, target[b] - target[a]) + Int.random(in: 0...50, using: &random)])
        }
        links.shuffle(using: &random)
        #expect(SignalSpreadTime.spreadTime(n: n, links: links, source: 0) == target.max()!)

        // One more server that nothing links to
        #expect(SignalSpreadTime.spreadTime(n: n + 1, links: links, source: 0) == -1)
    }

    @Test("A long chain of 50,000 servers")
    func chain() {
        let n = 50_000
        let links = (0..<(n - 1)).map { [$0, $0 + 1, 3] } + (0..<(n - 1)).map { [$0 + 1, $0, 1] }
        #expect(SignalSpreadTime.spreadTime(n: n, links: links, source: 0) == 3 * (n - 1))
        #expect(SignalSpreadTime.spreadTime(n: n, links: links, source: n - 1) == n - 1)
        #expect(SignalSpreadTime.spreadTime(n: n, links: links, source: n / 2) == 3 * (n - 1 - n / 2))
    }
}
