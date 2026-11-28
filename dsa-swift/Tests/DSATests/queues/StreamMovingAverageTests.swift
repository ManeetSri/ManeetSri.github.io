import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct StreamMovingAverageTests {
    typealias MovingAverage = StreamMovingAverage.MovingAverage

    private func close(_ a: Double, _ b: Double) -> Bool {
        abs(a - b) <= 1e-9 * max(1, abs(b))
    }

    private func averages(windowSize: Int, _ values: [Int]) -> [Double] {
        var average = MovingAverage(windowSize: windowSize)
        return values.map { average.next($0) }
    }

    @Test("Averages the last few values", arguments: [
        (3, [10, 20, 30, 40, 50, 0], [10.0, 15.0, 20.0, 30.0, 40.0, 30.0]),
        (2, [4, 8, 6, 2], [4.0, 6.0, 7.0, 4.0]),
        (1, [5, -3, 9], [5.0, -3.0, 9.0]),
        (4, [1, 2], [1.0, 1.5]),
        (3, [-6, 0, 3, 9], [-6.0, -3.0, -1.0, 4.0]),
        (2, [1, 2, 3, 4, 5], [1.0, 1.5, 2.5, 3.5, 4.5]),
    ])
    func examples(windowSize: Int, values: [Int], expected: [Double]) {
        let actual = averages(windowSize: windowSize, values)
        #expect(actual.count == expected.count)
        #expect(zip(actual, expected).allSatisfy { close($0, $1) }, "got \(actual)")
    }

    @Test("Separate averages don't share state")
    func independent() {
        var short = MovingAverage(windowSize: 1)
        var long = MovingAverage(windowSize: 10)
        #expect(close(short.next(10), 10))
        #expect(close(long.next(20), 20))
        #expect(close(short.next(30), 30))
        #expect(close(long.next(40), 30))
    }

    @Test("Handles very large and very small values")
    func extremes() {
        let actual = averages(windowSize: 2, [1_000_000_000, 1_000_000_000, -1_000_000_000])
        #expect(zip(actual, [1e9, 1e9, 0.0]).allSatisfy { close($0, $1) }, "got \(actual)")
    }

    @Test("Matches a direct average on many small streams")
    func matchesBruteForce() {
        var firstMismatch: String? = nil
        for windowSize in 1...6 {
            let values = (0..<40).map { ($0 * 37 + windowSize * 11) % 23 - 11 }
            let actual = averages(windowSize: windowSize, values)
            for index in values.indices {
                let window = values[Swift.max(0, index - windowSize + 1)...index]
                let expected = Double(window.reduce(0, +)) / Double(window.count)
                if index >= actual.count || !close(actual[index], expected) {
                    firstMismatch = firstMismatch ?? "window size \(windowSize), position \(index)"
                }
            }
        }
        #expect(firstMismatch == nil, "the first window size and position where the average is wrong")
    }

    @Test("Stays O(1) per value over a million values with a window of 5,000")
    func large() {
        let windowSize = 5_000
        var average = MovingAverage(windowSize: windowSize)
        var lastFew: [Double] = []
        for index in 0..<1_000_000 {
            let result = average.next(index % 1_000)
            if index >= 999_997 { lastFew.append(result) }
        }
        // The last 5,000 values are five full runs of 0...999, averaging 499.5 each time
        #expect(lastFew.count == 3)
        #expect(lastFew.allSatisfy { close($0, 499.5) }, "got \(lastFew)")
    }
}
