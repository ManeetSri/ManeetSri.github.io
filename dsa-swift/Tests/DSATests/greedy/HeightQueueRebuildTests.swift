import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct QueueRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct HeightQueueRebuildTests {
    /// The [height, k] clues for a queue of heights, front first
    private func clues(_ heights: [Int]) -> [[Int]] {
        heights.indices.map { i in [heights[i], heights[..<i].filter { $0 >= heights[i] }.count] }
    }

    /// True if `queue` holds exactly the people in `people` and everyone's clue is right
    private func isValid(_ queue: [[Int]], for people: [[Int]]) -> Bool {
        guard queue.count == people.count else { return false }
        let byPair = { (a: [Int], b: [Int]) in (a[0], a[1]) < (b[0], b[1]) }
        guard queue.sorted(by: byPair) == people.sorted(by: byPair) else { return false }
        return clues(queue.map { $0[0] }) == queue
    }

    @Test("Examples and small cases", arguments: [
        ([[4, 4], [7, 0], [5, 2], [6, 0], [4, 1], [6, 2]], [[6, 0], [4, 1], [7, 0], [5, 2], [4, 4], [6, 2]]),
        ([[5, 0], [3, 1], [5, 1]], [[5, 0], [3, 1], [5, 1]]),
        ([[8, 0]], [[8, 0]]),
        ([], []),
        ([[2, 2], [2, 0], [2, 1]], [[2, 0], [2, 1], [2, 2]]),
        ([[3, 0], [1, 0], [2, 0]], [[1, 0], [2, 0], [3, 0]]),
        ([[3, 0], [2, 1], [1, 2]], [[3, 0], [2, 1], [1, 2]]),
        ([[9, 1], [1, 0], [9, 0], [1, 3]], [[1, 0], [9, 0], [9, 1], [1, 3]]),
    ] as [([[Int]], [[Int]])])
    func examples(people: [[Int]], expected: [[Int]]) {
        #expect(HeightQueueRebuild.rebuild(people) == expected)
    }

    @Test("Rebuilds 1,000 small random queues from their shuffled clues")
    func randomSmall() {
        var random = QueueRandom(seed: 50)
        for _ in 0..<1_000 {
            // Few distinct heights, so there are plenty of ties
            let heights = (0..<Int.random(in: 1...8, using: &random)).map { _ in Int.random(in: 1...4, using: &random) }
            let queue = clues(heights)
            let shuffled = queue.shuffled(using: &random)
            let rebuilt = HeightQueueRebuild.rebuild(shuffled)
            #expect(rebuilt == queue, "clues \(shuffled)")
            #expect(isValid(rebuilt, for: shuffled))
        }
    }

    @Test("Rebuilds a queue of 2,000 people")
    func large() {
        var random = QueueRandom(seed: 2_026)
        let heights = (0..<2_000).map { _ in Int.random(in: 1...1_000_000, using: &random) }
        let queue = clues(heights)
        let shuffled = queue.shuffled(using: &random)
        #expect(HeightQueueRebuild.rebuild(shuffled) == queue)

        // Everyone the same height: k is simply the position
        let same = clues(Array(repeating: 170, count: 2_000))
        #expect(HeightQueueRebuild.rebuild(same.shuffled(using: &random)) == same)

        // Shortest at the front, tallest at the back: everyone has k = 0
        let rising = clues(Array(1...2_000))
        #expect(HeightQueueRebuild.rebuild(rising.shuffled(using: &random)) == rising)
    }
}
