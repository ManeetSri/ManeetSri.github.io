import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct MostWaterContainerTests {
    private static func slowMax(_ heights: [Int]) -> Int {
        var best = 0
        for i in heights.indices {
            for j in (i + 1)..<heights.count {
                best = max(best, min(heights[i], heights[j]) * (j - i))
            }
        }
        return best
    }

    @Test("Finds the most water", arguments: [
        ([3, 7, 2, 5, 4, 8, 3, 6], 36),
        ([2, 9, 9, 3], 9),
        ([4, 2, 6, 3, 5], 16),
        ([1, 2, 3, 4, 5], 6),
        ([5, 4, 3, 2, 1], 6),
        ([1, 1], 1),
        ([0, 0, 0], 0),
        ([6, 0, 0, 0, 0, 6], 30),
    ])
    func maxWater(heights: [Int], expected: Int) {
        #expect(MostWaterContainer.maxWater(heights: heights) == expected)
    }

    @Test("Fewer than two walls hold nothing", arguments: [[Int](), [5]])
    func tooFewWalls(heights: [Int]) {
        #expect(MostWaterContainer.maxWater(heights: heights) == 0)
    }

    @Test("Matches checking every pair on many small arrays")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<400 {
            let heights = (0..<(seed % 10)).map { ($0 * 7 + seed * 5) % 9 }
            if MostWaterContainer.maxWater(heights: heights) != Self.slowMax(heights) {
                firstMismatch = firstMismatch ?? heights
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 walls")
    func large() {
        let rising = Array(1...100_000)
        #expect(MostWaterContainer.maxWater(heights: rising) == 2_500_000_000)

        let flat = Array(repeating: 7, count: 100_000)
        #expect(MostWaterContainer.maxWater(heights: flat) == 7 * 99_999)
    }
}
