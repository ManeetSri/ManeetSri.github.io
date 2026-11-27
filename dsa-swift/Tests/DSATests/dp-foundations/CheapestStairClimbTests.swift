import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct CheapestClimbRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CheapestStairClimbTests {
    /// Try every route from the ground (position 0) to the landing (position n + 1). Exponential.
    private func everyRoute(_ tolls: [Int], _ maxStep: Int) -> Int {
        let landing = tolls.count + 1
        func cheapest(from position: Int) -> Int {
            if position == landing {
                return 0
            }
            var best = Int.max
            for step in 1...maxStep where position + step <= landing {
                let toll = position + step == landing ? 0 : tolls[position + step - 1]
                best = min(best, toll + cheapest(from: position + step))
            }
            return best
        }
        return cheapest(from: 0)
    }

    /// The same answer in O(n), keeping the cheapest of the last maxStep positions in a monotonic deque:
    /// position indexes whose costs increase from front to back
    private func slidingMinimum(_ tolls: [Int], _ maxStep: Int) -> Int {
        let landing = tolls.count + 1
        var cost = Array(repeating: 0, count: landing + 1)
        var window = [0]                  // the deque, stored in an array with a head index
        var head = 0
        for position in 1...landing {
            if window[head] < position - maxStep {
                head += 1                 // the cheapest is too far below to reach in one move
            }
            let toll = position == landing ? 0 : tolls[position - 1]
            cost[position] = cost[window[head]] + toll
            while window.count > head && cost[window[window.count - 1]] >= cost[position] {
                window.removeLast()       // never cheaper than this position again
            }
            window.append(position)
        }
        return cost[landing]
    }

    @Test("Examples and small cases", arguments: [
        ([4, 2, 7, 1, 8, 3], 2, 6),
        ([4, 2, 7, 1, 8, 3], 3, 3),
        ([3, 8, 2, 9, 4, 1, 7], 2, 10),
        ([9, 9, 9, 9], 4, 9),
        ([9, 9, 9, 9], 5, 0),
        ([5], 1, 5),
        ([5], 2, 0),
        ([], 3, 0),
        ([], 1, 0),
        ([1, 6, 1, 6, 6, 1, 6], 2, 9),
        ([10, 1, 10, 10, 1, 10, 10, 10, 1], 3, 12),
        ([2, 3, 4], 1, 9),
    ] as [([Int], Int, Int)])
    func examples(tolls: [Int], maxStep: Int, expected: Int) {
        #expect(CheapestStairClimb.minimumToll(tolls: tolls, maxStep: maxStep) == expected)
    }

    @Test("Matches trying every route on 400 small staircases")
    func randomSmall() {
        var random = CheapestClimbRandom(seed: 746)
        for _ in 0..<400 {
            let tolls = (0..<Int.random(in: 0...11, using: &random)).map { _ in Int.random(in: 0...20, using: &random) }
            let maxStep = Int.random(in: 1...4, using: &random)
            #expect(CheapestStairClimb.minimumToll(tolls: tolls, maxStep: maxStep) == everyRoute(tolls, maxStep),
                    "tolls \(tolls), maxStep \(maxStep)")
        }
    }

    @Test("100,000 stairs with the same toll everywhere", arguments: [1, 2, 7, 50])
    func evenTolls(maxStep: Int) {
        // Covering n + 1 positions with moves of at most maxStep needs ceil((n + 1) / maxStep) moves,
        // and every move except the last lands on a stair
        let n = 100_000
        let moves = (n + 1 + maxStep - 1) / maxStep
        #expect(CheapestStairClimb.minimumToll(tolls: Array(repeating: 5, count: n), maxStep: maxStep) == 5 * (moves - 1))
    }

    @Test("100,000 stairs with random tolls")
    func randomLarge() {
        var random = CheapestClimbRandom(seed: 100_000)
        for maxStep in [2, 13, 50] {
            let tolls = (0..<100_000).map { _ in Int.random(in: 0...10_000, using: &random) }
            #expect(CheapestStairClimb.minimumToll(tolls: tolls, maxStep: maxStep) == slidingMinimum(tolls, maxStep))
        }
    }
}
