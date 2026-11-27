import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BestAverageWindowTests {
    // Exact averages are compared with a tiny tolerance, so dividing in a different order still passes
    private func close(_ a: Double, _ b: Double) -> Bool {
        abs(a - b) < 1e-9
    }

    @Test("Finds the best average of k neighbours", arguments: [
        ([4, -2, 7, 3, -6, 10, 1], 2, 5.5),
        ([4, -2, 7, 3, -6, 10, 1], 4, 3.5),
        ([1, 2, 3, 4], 4, 2.5),
        ([5], 1, 5.0),
        ([-3, -1, -4], 1, -1.0),
        ([-3, -1, -4], 2, -2.0),
        ([0, 0, 0, 9], 3, 3.0),
        ([9, 0, 0, 0], 3, 3.0),
    ])
    func examples(values: [Int], k: Int, expected: Double) {
        #expect(close(BestAverageWindow.maxAverage(values, k: k), expected))
    }

    @Test("Handles an average that isn't a whole number")
    func fractional() {
        #expect(close(BestAverageWindow.maxAverage([1, 2, 2, 1], k: 3), 5.0 / 3.0))
    }

    @Test("Matches a brute force on many small arrays")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 1...300 {
            let count = seed % 9 + 1
            let values = (0..<count).map { ($0 * 37 + seed * 11) % 21 - 10 }
            for k in 1...count {
                var bestSum = Int.min
                for start in 0...(count - k) {
                    bestSum = max(bestSum, values[start..<start + k].reduce(0, +))
                }
                if !close(BestAverageWindow.maxAverage(values, k: k), Double(bestSum) / Double(k)) {
                    firstMismatch = firstMismatch ?? values
                }
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 values with a 50,000-value window")
    func large() {
        // Values 1, 2, 3, ... so the last window is the best: 50,001 ... 100,000, averaging 75,000.5
        let values = Array(1...100_000)
        #expect(close(BestAverageWindow.maxAverage(values, k: 50_000), 75_000.5))
        #expect(close(BestAverageWindow.maxAverage(values.reversed(), k: 50_000), 75_000.5))
    }
}
