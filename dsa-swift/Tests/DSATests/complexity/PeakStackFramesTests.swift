import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PeakStackFramesTests {
    // The recursions from the statement, with a depth counter, for small n
    static func measuredRangeSum(_ n: Int) -> Int {
        var depth = 0
        var peak = 0
        func sumRange(_ low: Int, _ high: Int) -> Int {
            depth += 1
            peak = max(peak, depth)
            defer { depth -= 1 }
            if low == high {
                return low
            }
            let mid = (low + high) / 2
            return sumRange(low, mid) + sumRange(mid + 1, high)
        }
        _ = sumRange(1, n)
        return peak
    }

    static func measuredTrim(_ n: Int) -> Int {
        var depth = 0
        var peak = 0
        func trim(_ n: Int) {
            depth += 1
            peak = max(peak, depth)
            defer { depth -= 1 }
            if n <= 1 {
                return
            }
            trim(n / 3)
            trim(n - 2)
        }
        trim(n)
        return peak
    }

    @Test("Range sum examples", arguments: [(1, 1), (2, 2), (3, 3), (4, 3), (5, 4), (8, 4), (9, 5), (100, 8), (1_000, 11)])
    func rangeSumExamples(n: Int, expected: Int) {
        #expect(PeakStackFrames.rangeSumFrames(n) == expected)
    }

    @Test("Range sum matches the measured recursion for every n up to 1,500")
    func rangeSumMatches() {
        let wrong = (1...1_500).filter { PeakStackFrames.rangeSumFrames($0) != Self.measuredRangeSum($0) }
        #expect(wrong.isEmpty, "wrong for n = \(Array(wrong.prefix(5)))")
    }

    @Test("Range sum for huge n, around powers of two")
    func rangeSumHuge() {
        #expect(PeakStackFrames.rangeSumFrames(1 << 40) == 41)
        #expect(PeakStackFrames.rangeSumFrames((1 << 40) + 1) == 42)
        #expect(PeakStackFrames.rangeSumFrames(1 << 60) == 61)
        #expect(PeakStackFrames.rangeSumFrames((1 << 60) + 1) == 62)
        #expect(PeakStackFrames.rangeSumFrames(1_000_000_000_000_000_000) == 61)
    }

    @Test("Trim examples", arguments: [(0, 1), (1, 1), (2, 2), (3, 2), (4, 3), (5, 3), (10, 6), (11, 6)])
    func trimExamples(n: Int, expected: Int) {
        #expect(PeakStackFrames.trimFrames(n) == expected)
    }

    @Test("Trim matches the measured recursion for every n up to 120")
    func trimMatches() {
        let wrong = (0...120).filter { PeakStackFrames.trimFrames($0) != Self.measuredTrim($0) }
        #expect(wrong.isEmpty, "wrong for n = \(Array(wrong.prefix(5)))")
    }

    @Test("Trim for huge n")
    func trimHuge() {
        #expect(PeakStackFrames.trimFrames(1_000_000_000_000_000_000) == 500_000_000_000_000_001)
        #expect(PeakStackFrames.trimFrames(999_999_999_999_999_999) == 500_000_000_000_000_000)
    }
}
