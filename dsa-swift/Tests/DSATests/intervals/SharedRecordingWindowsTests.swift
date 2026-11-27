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

@Suite struct SharedRecordingWindowsTests {
    /// Intersects every pair of windows: O(m × n), but clearly right
    private func bruteForce(_ first: [[Int]], _ second: [[Int]]) -> [[Int]] {
        var result: [[Int]] = []
        for a in first {
            for b in second {
                let start = max(a[0], b[0])
                let end = min(a[1], b[1])
                if start <= end {
                    result.append([start, end])
                }
            }
        }
        return result.sorted { $0[0] < $1[0] }
    }

    /// A sorted list of closed windows in which no two share a second
    private func windows(_ random: inout IntervalRandom) -> [[Int]] {
        var list: [[Int]] = []
        var cursor = Int.random(in: 0...4, using: &random)
        for _ in 0..<Int.random(in: 0...6, using: &random) {
            let length = Int.random(in: 0...5, using: &random)
            list.append([cursor, cursor + length])
            cursor += length + Int.random(in: 1...4, using: &random)
        }
        return list
    }

    @Test("Finds the shared windows", arguments: [
        ([[0, 4], [7, 10]], [[2, 8]], [[2, 4], [7, 8]]),
        ([[1, 5]], [[5, 9]], [[5, 5]]),
        ([[1, 3], [6, 9]], [[4, 5]], []),
        ([[0, 10]], [[1, 2], [4, 6], [9, 12]], [[1, 2], [4, 6], [9, 10]]),
        ([[0, 2], [5, 10], [13, 23], [24, 25]], [[1, 5], [8, 12], [15, 24], [25, 26]],
         [[1, 2], [5, 5], [8, 10], [15, 23], [24, 24], [25, 25]]),
        ([[1, 3], [5, 8]], [[1, 3], [5, 8]], [[1, 3], [5, 8]]),
        ([[-6, -2], [0, 3]], [[-3, 1]], [[-3, -2], [0, 1]]),
    ] as [([[Int]], [[Int]], [[Int]])])
    func examples(first: [[Int]], second: [[Int]], expected: [[Int]]) {
        #expect(SharedRecordingWindows.sharedWindows(first, second) == expected)
        #expect(SharedRecordingWindows.sharedWindows(second, first) == expected)
    }

    @Test("An empty list shares nothing")
    func empty() {
        #expect(SharedRecordingWindows.sharedWindows([], [[1, 2]]) == [])
        #expect(SharedRecordingWindows.sharedWindows([[1, 2]], []) == [])
        #expect(SharedRecordingWindows.sharedWindows([], []) == [])
    }

    @Test("Matches intersecting every pair on many small inputs")
    func matchesBruteForce() {
        var random = IntervalRandom(seed: 44)
        var firstMismatch: String? = nil
        for _ in 0..<600 {
            let first = windows(&random)
            let second = windows(&random)
            if SharedRecordingWindows.sharedWindows(first, second) != bruteForce(first, second) {
                firstMismatch = firstMismatch ?? "\(first) and \(second)"
            }
        }
        #expect(firstMismatch == nil, "the first input where the answer differs from the brute force")
    }

    @Test("Handles two lists of 100,000 windows in O(m + n)")
    func large() {
        let n = 100_000
        let first = (0..<n).map { [4 * $0, 4 * $0 + 2] }
        let second = (0..<n).map { [4 * $0 + 2, 4 * $0 + 5] }
        // Window k of the first list meets window k of the second at a single second, 4k + 2,
        // and window k + 1 of the first meets window k of the second for [4k + 4, 4k + 5]
        var expected: [[Int]] = []
        for k in 0..<n {
            expected.append([4 * k + 2, 4 * k + 2])
            if k + 1 < n {
                expected.append([4 * k + 4, 4 * k + 5])
            }
        }
        #expect(SharedRecordingWindows.sharedWindows(first, second) == expected)
    }
}
