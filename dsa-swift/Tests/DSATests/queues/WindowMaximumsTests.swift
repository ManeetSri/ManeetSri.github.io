import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct WindowMaximumsTests {
    private func bruteForce(_ values: [Int], _ k: Int) -> [Int] {
        (0...(values.count - k)).map { start in values[start..<(start + k)].max()! }
    }

    @Test("Finds the maximum of every window", arguments: [
        ([4, 2, 12, 3, 1, 8, 5], 3, [12, 12, 12, 8, 8]),
        ([1, 3, 2, 5, 4], 2, [3, 3, 5, 5]),
        ([9, 7, 5, 3, 1], 2, [9, 7, 5, 3]),
        ([1, 2, 3, 4, 5], 3, [3, 4, 5]),
        ([5, 5, 5, 5], 2, [5, 5, 5]),
        ([2, 1, 2, 1, 2], 2, [2, 2, 2, 2]),
        ([-4, -2, -7, -1], 2, [-2, -2, -1]),
        ([6], 1, [6]),
    ])
    func examples(values: [Int], k: Int, expected: [Int]) {
        #expect(WindowMaximums.maxima(in: values, windowSize: k) == expected)
    }

    @Test("A window of 1 returns every value")
    func windowOfOne() {
        let values = [3, -1, 4, 1, -5, 9]
        #expect(WindowMaximums.maxima(in: values, windowSize: 1) == values)
    }

    @Test("A window as long as the array returns its maximum")
    func wholeArray() {
        #expect(WindowMaximums.maxima(in: [3, 8, -2, 8, 1], windowSize: 5) == [8])
    }

    @Test("Handles the extremes of Int")
    func extremes() {
        #expect(WindowMaximums.maxima(in: [Int.min, Int.max, Int.min], windowSize: 2) == [Int.max, Int.max])
        #expect(WindowMaximums.maxima(in: [Int.min, Int.min], windowSize: 1) == [Int.min, Int.min])
    }

    @Test("An old maximum leaves the window on time")
    func expiry() {
        // 10 must stop counting as soon as its window has passed
        #expect(WindowMaximums.maxima(in: [10, 1, 2, 3, 4], windowSize: 3) == [10, 3, 4])
    }

    @Test("Matches a brute force on many small arrays")
    func matchesBruteForce() {
        var firstMismatch: String? = nil
        for seed in 1..<300 {
            let count = seed % 12 + 1
            let values = (0..<count).map { ($0 * 7 + seed * 13) % 9 - 4 }
            for k in 1...count {
                if WindowMaximums.maxima(in: values, windowSize: k) != bruteForce(values, k) {
                    firstMismatch = firstMismatch ?? "\(values) with k = \(k)"
                }
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Runs in O(n) on 200,000 values with a window of 20,000")
    func large() {
        let n = 200_000
        let k = 20_000
        // Values rise and fall in waves, so the deque both grows and empties
        let values = (0..<n).map { ($0 * 7_919) % 100_003 }
        let result = WindowMaximums.maxima(in: values, windowSize: k)
        #expect(result.count == n - k + 1)
        // Spot-check a few windows directly
        for start in [0, 1, 12_345, 99_999, n - k] {
            let expected = values[start..<(start + k)].max()
            #expect(start < result.count && result[start] == expected)
        }
        // A strictly decreasing array: every answer is the window's first value
        let falling = Array((0..<n).reversed())
        #expect(WindowMaximums.maxima(in: falling, windowSize: k) == Array((k - 1..<n).reversed()))
    }
}
