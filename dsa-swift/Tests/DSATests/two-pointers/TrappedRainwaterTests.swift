import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TrappedRainwaterTests {
    /// Prefix and suffix maximums: an independent O(n) answer to check against.
    private static func withArrays(_ heights: [Int]) -> Int {
        let n = heights.count
        guard n > 0 else { return 0 }
        var leftMax = heights
        var rightMax = heights
        for i in stride(from: 1, to: n, by: 1) {
            leftMax[i] = max(leftMax[i - 1], heights[i])
        }
        for i in stride(from: n - 2, through: 0, by: -1) {
            rightMax[i] = max(rightMax[i + 1], heights[i])
        }
        return (0..<n).reduce(0) { $0 + min(leftMax[$1], rightMax[$1]) - heights[$1] }
    }

    @Test("Adds up the trapped water", arguments: [
        ([4, 1, 3, 0, 2, 5, 1, 2], 11),
        ([3, 0, 1, 0, 2], 5),
        ([5, 2, 5], 3),
        ([3, 0, 0, 2, 0, 4], 10),
        ([2, 0, 2], 2),
        ([1, 0, 2, 0, 1], 2),
        ([0, 4, 0, 0, 4, 0], 8),
    ])
    func trapped(heights: [Int], expected: Int) {
        #expect(TrappedRainwater.trappedWater(heights: heights) == expected)
    }

    @Test("No dips means no water", arguments: [
        [Int](), [7], [1, 2, 3], [3, 2, 1], [0, 0, 0], [1, 3, 3, 1], [2, 2],
    ])
    func noWater(heights: [Int]) {
        #expect(TrappedRainwater.trappedWater(heights: heights) == 0)
    }

    @Test("Matches scanning both ways at every bar on many small landscapes")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<500 {
            let heights = (0..<(seed % 11)).map { ($0 * 7 + seed * 13) % 6 }
            var expected = 0
            for i in heights.indices {
                expected += min(heights[...i].max()!, heights[i...].max()!) - heights[i]
            }
            if TrappedRainwater.trappedWater(heights: heights) != expected {
                firstMismatch = firstMismatch ?? heights
            }
        }
        #expect(firstMismatch == nil, "the first landscape where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 bars")
    func large() {
        let walls = [100_000] + Array(repeating: 0, count: 99_998) + [100_000]
        #expect(TrappedRainwater.trappedWater(heights: walls) == 99_998 * 100_000)

        let valley = (0..<100_000).map { abs($0 - 50_000) }
        #expect(TrappedRainwater.trappedWater(heights: valley) == Self.withArrays(valley))

        let jagged = (0..<100_000).map { ($0 * 7_919) % 1_000 }
        #expect(TrappedRainwater.trappedWater(heights: jagged) == Self.withArrays(jagged))
    }
}
