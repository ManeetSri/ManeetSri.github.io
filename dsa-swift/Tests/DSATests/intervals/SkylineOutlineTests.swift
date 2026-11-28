import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct IntervalRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SkylineOutlineTests {
    /// At every building edge, the height is the tallest building covering it: O(n²), but clearly right
    private func bruteForce(_ buildings: [[Int]]) -> [[Int]] {
        let edges = Set(buildings.flatMap { [$0[0], $0[1]] }).sorted()
        var points: [[Int]] = []
        for x in edges {
            var height = 0
            for building in buildings where building[0] <= x && x < building[1] {
                height = max(height, building[2])
            }
            if points.last?[1] != height {
                points.append([x, height])
            }
        }
        return points
    }

    /// A city of up to `count` buildings at small coordinates, so edges and heights often coincide
    private func city(_ random: inout IntervalRandom, count: Int, width: Int, tallest: Int) -> [[Int]] {
        (0..<count).map { _ in
            let left = Int.random(in: 0...width, using: &random)
            return [left, left + Int.random(in: 1...(width / 2 + 1), using: &random), Int.random(in: 1...tallest, using: &random)]
        }
    }

    @Test("Finds the key points", arguments: [
        ([[0, 4, 5], [2, 7, 3], [5, 9, 6], [11, 13, 2]], [[0, 5], [4, 3], [5, 6], [9, 0], [11, 2], [13, 0]]),
        ([[1, 3, 4], [3, 6, 4]], [[1, 4], [6, 0]]),
        ([[2, 9, 8], [3, 5, 4]], [[2, 8], [9, 0]]),
        ([[1, 4, 2], [1, 4, 6]], [[1, 6], [4, 0]]),
        ([[0, 2, 3], [5, 6, 1]], [[0, 3], [2, 0], [5, 1], [6, 0]]),
        ([[1, 5, 3], [2, 4, 6], [3, 8, 4], [10, 12, 2]], [[1, 3], [2, 6], [4, 4], [8, 0], [10, 2], [12, 0]]),
        ([[3, 7, 9]], [[3, 9], [7, 0]]),
    ] as [([[Int]], [[Int]])])
    func examples(buildings: [[Int]], expected: [[Int]]) {
        #expect(SkylineOutline.keyPoints(buildings) == expected)
    }

    @Test("No buildings, no outline")
    func empty() {
        #expect(SkylineOutline.keyPoints([]) == [])
    }

    @Test("Several events at one x give at most one key point")
    func ties() {
        // Three starts and three ends at the same x
        #expect(SkylineOutline.keyPoints([[1, 4, 2], [1, 4, 7], [1, 4, 5]]) == [[1, 7], [4, 0]])
        // Neighbours of equal height make one flat stretch, with no dip where they meet
        #expect(SkylineOutline.keyPoints([[0, 5, 3], [5, 10, 3], [10, 15, 3]]) == [[0, 3], [15, 0]])
        // A staircase going down from one shared left edge
        #expect(SkylineOutline.keyPoints([[0, 6, 2], [0, 4, 4], [0, 2, 6]]) == [[0, 6], [2, 4], [4, 2], [6, 0]])
        // One ends where a shorter one starts, and where a taller one starts
        #expect(SkylineOutline.keyPoints([[0, 3, 5], [3, 6, 2], [6, 8, 9]]) == [[0, 5], [3, 2], [6, 9], [8, 0]])
    }

    @Test("Overlapping buildings of the same height count separately")
    func duplicateHeights() {
        #expect(SkylineOutline.keyPoints([[0, 4, 5], [2, 6, 5]]) == [[0, 5], [6, 0]])
        #expect(SkylineOutline.keyPoints([[0, 10, 5], [2, 4, 5], [2, 4, 5]]) == [[0, 5], [10, 0]])
    }

    @Test("The order of the buildings doesn't matter")
    func anyOrder() {
        let buildings = [[1, 5, 3], [2, 4, 6], [3, 8, 4], [10, 12, 2]]
        let expected = [[1, 3], [2, 6], [4, 4], [8, 0], [10, 2], [12, 0]]
        #expect(SkylineOutline.keyPoints(Array(buildings.reversed())) == expected)
        #expect(SkylineOutline.keyPoints([buildings[2], buildings[0], buildings[3], buildings[1]]) == expected)
    }

    @Test("Matches the brute force on many small cities")
    func matchesBruteForce() {
        var random = IntervalRandom(seed: 271)
        var firstMismatch: String? = nil
        for _ in 0..<600 {
            let buildings = city(&random, count: Int.random(in: 0...8, using: &random), width: 12, tallest: 5)
            if SkylineOutline.keyPoints(buildings) != bruteForce(buildings) {
                firstMismatch = firstMismatch ?? "\(buildings)"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Handles 10,000 buildings")
    func large() {
        let n = 10_000
        var random = IntervalRandom(seed: 314)

        // A pyramid: building i spans [i, 2n - i] with height i + 1, so the outline climbs one step at
        // each x from 0 to n - 1, then falls one step at each x from n + 1 to 2n
        let pyramid = (0..<n).map { [$0, 2 * n - $0, $0 + 1] }.shuffled(using: &random)
        let climb = (0..<n).map { [$0, $0 + 1] }
        let fall = (0..<n).reversed().map { [2 * n - $0, $0] }
        #expect(SkylineOutline.keyPoints(pyramid) == climb + fall)

        // Nested buildings that get shorter towards the middle: every one is hidden by the outermost
        let hidden = (0..<n).map { [$0, 2 * n - $0, n - $0] }.shuffled(using: &random)
        #expect(SkylineOutline.keyPoints(hidden) == [[0, n], [2 * n, 0]])

        // A random city of 2,000 buildings, checked against the brute force
        let buildings = city(&random, count: 2_000, width: 5_000, tallest: 300)
        #expect(SkylineOutline.keyPoints(buildings) == bruteForce(buildings))
    }
}
