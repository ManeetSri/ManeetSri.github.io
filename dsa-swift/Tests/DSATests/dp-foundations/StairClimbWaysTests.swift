import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct StairClimbRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct StairClimbWaysTests {
    private let modulus = 1_000_000_007

    /// Try every sequence of moves. Exponential, but clearly right.
    private func everyClimb(_ stairs: Int, _ steps: [Int], _ broken: [Int]) -> Int {
        let blocked = Set(broken)
        func climb(from position: Int) -> Int {
            if position == stairs {
                return 1
            }
            var total = 0
            for step in steps where position + step <= stairs && !blocked.contains(position + step) {
                total += climb(from: position + step)
            }
            return total
        }
        return climb(from: 0)
    }

    /// The same count, pushed forwards: each reachable stair hands its count to the stairs it can reach
    private func pushedForwards(_ stairs: Int, _ steps: [Int], _ broken: [Int]) -> Int {
        var blocked = Array(repeating: false, count: stairs + 1)
        for stair in broken {
            blocked[stair] = true
        }
        var ways = Array(repeating: 0, count: stairs + 1)
        ways[0] = 1
        for position in 0..<max(stairs, 0) where ways[position] != 0 {
            for step in steps where position + step <= stairs && !blocked[position + step] {
                ways[position + step] = (ways[position + step] + ways[position]) % modulus
            }
        }
        return ways[stairs]
    }

    @Test("Examples and small cases", arguments: [
        (4, [1, 2], [], 5),
        (4, [1, 2], [2], 1),
        (10, [2, 5], [], 2),
        (7, [2, 4], [], 0),
        (0, [3], [], 1),
        (50, [1, 2], [], 365_010_934),
        (10, [1, 2, 3], [3, 6], 42),
        (12, [1, 3, 4], [5], 79),
        (5, [6], [], 0),
        (5, [5], [], 1),
        (1, [1], [], 1),
        (6, [1, 2], [2, 3], 0),
        (6, [1, 3], [2, 4], 1),
    ] as [(Int, [Int], [Int], Int)])
    func examples(stairs: Int, steps: [Int], broken: [Int], expected: Int) {
        #expect(StairClimbWays.count(stairs: stairs, steps: steps, broken: broken) == expected)
    }

    @Test("Matches trying every climb on 300 small staircases")
    func randomSmall() {
        var random = StairClimbRandom(seed: 51)
        for _ in 0..<300 {
            let stairs = Int.random(in: 0...16, using: &random)
            let steps = Set((0..<Int.random(in: 1...4, using: &random)).map { _ in Int.random(in: 1...6, using: &random) }).sorted()
            let broken = stairs < 2 ? [] : Set((0..<Int.random(in: 0...3, using: &random)).map { _ in Int.random(in: 1..<stairs, using: &random) }).sorted()
            #expect(StairClimbWays.count(stairs: stairs, steps: steps, broken: broken) == everyClimb(stairs, steps, broken),
                    "stairs \(stairs), steps \(steps), broken \(broken)")
        }
    }

    @Test("100,000 stairs, one or two at a time, reduced modulo 1,000,000,007")
    func longStaircase() {
        // The count is the Fibonacci number fib(100,001), far too big for an Int
        #expect(StairClimbWays.count(stairs: 100_000, steps: [1, 2], broken: []) == 967_618_232)
        #expect(StairClimbWays.count(stairs: 100_000, steps: [1], broken: []) == 1)
        #expect(StairClimbWays.count(stairs: 99_999, steps: [2, 4], broken: []) == 0)
    }

    @Test("Large staircases with many step sizes and broken stairs")
    func randomLarge() {
        var random = StairClimbRandom(seed: 2_051)
        for _ in 0..<2 {
            let stairs = 100_000
            let steps = Set((0..<20).map { _ in Int.random(in: 1...1_000, using: &random) }).sorted()
            let broken = Set((0..<10_000).map { _ in Int.random(in: 1..<stairs, using: &random) }).sorted()
            #expect(StairClimbWays.count(stairs: stairs, steps: steps, broken: broken) == pushedForwards(stairs, steps, broken))
        }
        // A broken stair every 3 stairs, with steps of 1 and 2: the only way past each is a 2-step over it,
        // so the climb is forced except at the very bottom (1 + 1 or 2 to reach stair 2) and the very top
        let everyThird = Array(stride(from: 3, to: 90_000, by: 3))
        #expect(StairClimbWays.count(stairs: 90_000, steps: [1, 2], broken: everyThird) == 4)
    }
}
