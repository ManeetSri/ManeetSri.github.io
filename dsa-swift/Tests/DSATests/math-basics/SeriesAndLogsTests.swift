import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SeriesAndLogsTests {
    @Test("Arithmetic examples", arguments: [
        (1, 1, 100, 5_050), (3, 4, 10, 210), (10, -3, 5, 20), (7, 0, 9, 63), (5, 5, 1, 5),
        (4, 2, 0, 0), (-5, 1, 11, 0), (-1_000_000_000, -1_000_000_000, 3, -6_000_000_000),
    ])
    func arithmeticExamples(first: Int, step: Int, count: Int, expected: Int) {
        #expect(SeriesAndLogs.arithmeticSum(first: first, step: step, count: count) == expected)
    }

    @Test("Arithmetic matches a loop for small inputs")
    func arithmeticMatchesLoop() {
        var wrong: [String] = []
        for first in -6...6 {
            for step in -4...4 {
                var total = 0
                for count in 0...40 {
                    if SeriesAndLogs.arithmeticSum(first: first, step: step, count: count) != total {
                        wrong.append("first \(first), step \(step), count \(count)")
                    }
                    total += first + count * step
                }
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
    }

    @Test("Arithmetic near the top of Int, where multiplying first overflows")
    func arithmeticHuge() {
        #expect(SeriesAndLogs.arithmeticSum(first: 1, step: 1, count: 4_000_000_000) == 8_000_000_002_000_000_000)
        #expect(SeriesAndLogs.arithmeticSum(first: 0, step: 1, count: 4_000_000_001) == 8_000_000_002_000_000_000)
        #expect(SeriesAndLogs.arithmeticSum(first: -1, step: -1, count: 4_000_000_000) == -8_000_000_002_000_000_000)
        #expect(SeriesAndLogs.arithmeticSum(first: 1_000_000_000, step: -1, count: 2_000_000_001) == 0)
        #expect(SeriesAndLogs.arithmeticSum(first: 1_000_000_000, step: 0, count: 4_000_000_000) == 4_000_000_000_000_000_000)
    }

    @Test("Geometric examples", arguments: [
        (2, 4, 15), (2, 0, 0), (2, 1, 1), (3, 5, 121), (10, 6, 111_111), (1_000_000_000, 2, 1_000_000_001),
    ])
    func geometricExamples(ratio: Int, terms: Int, expected: Int) {
        #expect(SeriesAndLogs.geometricSum(ratio: ratio, terms: terms) == expected)
    }

    @Test("Geometric sums that fit, though the next power doesn't")
    func geometricEdges() {
        #expect(SeriesAndLogs.geometricSum(ratio: 2, terms: 63) == Int.max)
        #expect(SeriesAndLogs.geometricSum(ratio: 2, terms: 62) == 4_611_686_018_427_387_903)
        #expect(SeriesAndLogs.geometricSum(ratio: 3, terms: 39) == 2_026_277_576_509_488_133)
        #expect(SeriesAndLogs.geometricSum(ratio: 3, terms: 40) == 6_078_832_729_528_464_400)
        #expect(SeriesAndLogs.geometricSum(ratio: 10, terms: 19) == 1_111_111_111_111_111_111)
        #expect(SeriesAndLogs.geometricSum(ratio: 1_000_000_000, terms: 3) == 1_000_000_001_000_000_001)
    }

    @Test("Floor logs", arguments: [
        (1_000, 10, 3), (999, 10, 2), (1, 2, 0), (1_024, 2, 10), (1_023, 2, 9), (243, 3, 5), (242, 3, 4),
        (1_000_000, 2, 19), (7, 8, 0), (1_000_000_000, 1_000_000_000, 1), (999_999_999, 1_000_000_000, 0),
    ])
    func floorLogs(n: Int, base: Int, expected: Int) {
        #expect(SeriesAndLogs.floorLog(n, base: base) == expected)
    }

    @Test("Floor logs at the top of Int")
    func floorLogHuge() {
        #expect(SeriesAndLogs.floorLog(Int.max, base: 2) == 62)
        #expect(SeriesAndLogs.floorLog(Int.max, base: 3) == 39)
        #expect(SeriesAndLogs.floorLog(Int.max, base: 10) == 18)
        #expect(SeriesAndLogs.floorLog(1_000_000_000_000_000_000, base: 10) == 18)
        #expect(SeriesAndLogs.floorLog(999_999_999_999_999_999, base: 10) == 17)
        #expect(SeriesAndLogs.floorLog(Int.max, base: 1_000_000_000) == 2)
    }

    @Test("Every exact power of every small base, and one below it")
    func exactPowers() {
        var wrong: [String] = []
        for base in 2...12 {
            var power = 1
            var exponent = 0
            while power <= Int.max / base {
                power *= base
                exponent += 1
                if SeriesAndLogs.floorLog(power, base: base) != exponent { wrong.append("\(base)^\(exponent)") }
                if SeriesAndLogs.floorLog(power - 1, base: base) != exponent - 1 { wrong.append("\(base)^\(exponent) − 1") }
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
    }
}
