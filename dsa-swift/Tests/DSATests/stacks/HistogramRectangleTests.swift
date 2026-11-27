import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct HistogramRectangleTests {
    @Test("Finds the largest rectangle in a histogram", arguments: [
        ([2, 1, 5, 6, 2, 3], 10),
        ([3, 1, 3, 2, 2], 6),
        ([4, 4, 4], 12),
        ([1, 2, 3, 4, 5], 9),
        ([5, 4, 3, 2, 1], 9),
        ([7], 7),
        ([0, 0], 0),
        ([2, 0, 2], 2),
        ([6, 2, 5, 4, 5, 1, 6], 12),
    ])
    func histogram(heights: [Int], expected: Int) {
        #expect(HistogramRectangle.largestArea(heights) == expected)
    }

    @Test("An empty histogram has no rectangle")
    func emptyHistogram() {
        #expect(HistogramRectangle.largestArea([]) == 0)
    }

    @Test("Matches a brute force on many small histograms")
    func matchesBruteForce() {
        func bruteForce(_ heights: [Int]) -> Int {
            var best = 0
            for start in heights.indices {
                var lowest = Int.max
                for end in start..<heights.count {
                    lowest = min(lowest, heights[end])
                    best = max(best, lowest * (end - start + 1))
                }
            }
            return best
        }
        var mismatches = 0
        for seed in 0..<400 {
            let heights = (0..<(seed % 10)).map { ($0 * 5 + seed * 7) % 6 }
            if HistogramRectangle.largestArea(heights) != bruteForce(heights) {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Finds the largest rectangle of 1s in a grid")
    func grid() {
        let grid = [
            [1, 0, 1, 0, 0],
            [1, 0, 1, 1, 1],
            [1, 1, 1, 1, 1],
            [1, 0, 0, 1, 0],
        ]
        #expect(HistogramRectangle.largestRectangle(in: grid) == 6)
        #expect(HistogramRectangle.largestRectangle(in: [[0, 0], [0, 0]]) == 0)
        #expect(HistogramRectangle.largestRectangle(in: [[1]]) == 1)
        #expect(HistogramRectangle.largestRectangle(in: [[1, 1, 0, 1, 1, 1]]) == 3)
        #expect(HistogramRectangle.largestRectangle(in: [[1], [1], [0], [1]]) == 2)
        #expect(HistogramRectangle.largestRectangle(in: []) == 0)
    }

    @Test("Stays fast on 100,000 bars")
    func large() {
        let rising = Array(1...100_000)
        // Best: height 50,000 across the 50,001 bars from 50,000 to 100,000
        #expect(HistogramRectangle.largestArea(rising) == 50_000 * 50_001)
        let flat = Array(repeating: 3, count: 100_000)
        #expect(HistogramRectangle.largestArea(flat) == 300_000)
    }

    @Test("Stays fast on a 300 × 300 grid")
    func largeGrid() {
        // All 1s except a diagonal of 0s from the top-left corner
        let grid = (0..<300).map { row in (0..<300).map { column in row == column ? 0 : 1 } }
        // The best rectangle avoids the diagonal: 150 × 150, either above-right or below-left
        #expect(HistogramRectangle.largestRectangle(in: grid) == 150 * 150)
    }
}
