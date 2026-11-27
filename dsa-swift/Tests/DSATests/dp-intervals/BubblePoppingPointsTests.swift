import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct BubbleRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BubblePoppingPointsTests {
    /// Tries popping each bubble next, on the row as it really is, remembering rows already solved
    private func bruteForce(_ bubbles: [Int], _ memo: inout [[Int]: Int]) -> Int {
        if bubbles.isEmpty { return 0 }
        if let known = memo[bubbles] { return known }
        var best = 0
        for i in bubbles.indices {
            let left = i > 0 ? bubbles[i - 1] : 1
            let right = i < bubbles.count - 1 ? bubbles[i + 1] : 1
            var rest = bubbles
            rest.remove(at: i)
            best = max(best, left * bubbles[i] * right + bruteForce(rest, &memo))
        }
        memo[bubbles] = best
        return best
    }

    /// The last-popped recurrence, top-down with a memo, for long rows
    private func reference(_ bubbles: [Int]) -> Int {
        let values = [1] + bubbles + [1]
        var memo = Array(repeating: Array(repeating: -1, count: values.count), count: values.count)
        func best(_ left: Int, _ right: Int) -> Int {
            if right - left < 2 { return 0 }
            if memo[left][right] >= 0 { return memo[left][right] }
            var answer = 0
            for last in (left + 1)..<right {
                answer = max(answer, best(left, last) + best(last, right) + values[left] * values[last] * values[right])
            }
            memo[left][right] = answer
            return answer
        }
        return best(0, values.count - 1)
    }

    @Test("Examples and edge cases", arguments: [
        ([4, 2, 6], 78),
        ([7, 1, 8, 2], 189),
        ([2, 3], 9),
        ([3, 0, 5, 1, 4], 96),
        ([9], 9),
        ([0, 0, 0], 0),
        ([], 0),
    ] as [([Int], Int)])
    func examples(bubbles: [Int], expected: Int) {
        #expect(BubblePoppingPoints.maxPoints(bubbles) == expected)
    }

    @Test("Matches trying every order on 300 short rows")
    func randomSmall() {
        var random = BubbleRandom(seed: 57)
        for _ in 0..<300 {
            let bubbles = (0..<Int.random(in: 0...7, using: &random)).map { _ in Int.random(in: 0...9, using: &random) }
            var memo: [[Int]: Int] = [:]
            #expect(BubblePoppingPoints.maxPoints(bubbles) == bruteForce(bubbles, &memo), "bubbles: \(bubbles)")
        }
    }

    @Test("Long rows")
    func large() {
        var random = BubbleRandom(seed: 300)
        let bubbles = (0..<150).map { _ in Int.random(in: 0...100, using: &random) }
        #expect(BubblePoppingPoints.maxPoints(bubbles) == reference(bubbles))

        // Every pop scores 1 · 1 · 1 whatever the order
        #expect(BubblePoppingPoints.maxPoints(Array(repeating: 1, count: 200)) == 200)
        #expect(BubblePoppingPoints.maxPoints(Array(repeating: 0, count: 200)) == 0)
    }
}
