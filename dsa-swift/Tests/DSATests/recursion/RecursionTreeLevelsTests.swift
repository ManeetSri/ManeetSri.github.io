import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RecursionTreeLevelsTests {
    // The recursions themselves, counting calls per level, for small n
    static func countedFibonacci(_ n: Int) -> [Int] {
        var counts: [Int] = []
        func fib(_ n: Int, _ level: Int) -> Int {
            if counts.count == level {
                counts.append(0)
            }
            counts[level] += 1
            if n < 2 {
                return n
            }
            return fib(n - 1, level + 1) + fib(n - 2, level + 1)
        }
        _ = fib(n, 0)
        return counts
    }

    static func countedHalves(_ n: Int) -> [Int] {
        var counts: [Int] = []
        let items = Array(1...n)
        func total(_ low: Int, _ high: Int, _ level: Int) -> Int {
            if counts.count == level {
                counts.append(0)
            }
            counts[level] += 1
            if low == high {
                return items[low]
            }
            let mid = (low + high) / 2
            return total(low, mid, level + 1) + total(mid + 1, high, level + 1)
        }
        _ = total(0, n - 1, 0)
        return counts
    }

    @Test("Fibonacci examples")
    func fibonacciExamples() {
        #expect(RecursionTreeLevels.fibonacciLevels(0) == [1])
        #expect(RecursionTreeLevels.fibonacciLevels(1) == [1])
        #expect(RecursionTreeLevels.fibonacciLevels(2) == [1, 2])
        #expect(RecursionTreeLevels.fibonacciLevels(3) == [1, 2, 2])
        #expect(RecursionTreeLevels.fibonacciLevels(4) == [1, 2, 4, 2])
        #expect(RecursionTreeLevels.fibonacciLevels(5) == [1, 2, 4, 6, 2])
        #expect(RecursionTreeLevels.fibonacciLevels(10) == [1, 2, 4, 8, 16, 32, 52, 44, 16, 2])
    }

    @Test("Fibonacci matches the counted recursion for n up to 20")
    func fibonacciMatches() {
        let wrong = (0...20).filter { RecursionTreeLevels.fibonacciLevels($0) != Self.countedFibonacci($0) }
        #expect(wrong.isEmpty, "wrong for n = \(wrong)")
    }

    @Test("fib(40) and fib(80): far too many calls to count one by one")
    func fibonacciLarge() throws {
        let forty = RecursionTreeLevels.fibonacciLevels(40)
        try #require(forty.count == 40)
        #expect(forty.reduce(0, +) == 331_160_281)
        #expect(Array(forty[18...21]) == [262_144, 524_288, 1_048_576, 2_097_110])
        #expect(forty.max() == 59_333_408)

        let eighty = RecursionTreeLevels.fibonacciLevels(80)
        try #require(eighty.count == 80)
        #expect(eighty.reduce(0, +) == 75_778_124_746_287_811)
        #expect(Array(eighty[38...41]) == [274_877_906_944, 549_755_813_888, 1_099_511_627_776, 2_199_023_255_470])
        #expect(eighty.max() == 10_152_585_235_461_218)
        #expect(Array(eighty.suffix(3)) == [5_854, 156, 2])
    }

    @Test("Halves examples")
    func halvesExamples() {
        #expect(RecursionTreeLevels.halvesLevels(1) == [1])
        #expect(RecursionTreeLevels.halvesLevels(2) == [1, 2])
        #expect(RecursionTreeLevels.halvesLevels(5) == [1, 2, 4, 2])
        #expect(RecursionTreeLevels.halvesLevels(6) == [1, 2, 4, 4])
        #expect(RecursionTreeLevels.halvesLevels(8) == [1, 2, 4, 8])
        #expect(RecursionTreeLevels.halvesLevels(13) == [1, 2, 4, 8, 10])
        #expect(RecursionTreeLevels.halvesLevels(1_000) == [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 976])
    }

    @Test("Halves match the counted recursion for n up to 400")
    func halvesMatch() {
        let wrong = (1...400).filter { RecursionTreeLevels.halvesLevels($0) != Self.countedHalves($0) }
        #expect(wrong.isEmpty, "wrong for n = \(Array(wrong.prefix(5)))")
    }

    @Test("Halves for up to 10¹⁸ items")
    func halvesHuge() {
        let quintillion = RecursionTreeLevels.halvesLevels(1_000_000_000_000_000_000)
        #expect(quintillion.count == 61)
        #expect(quintillion.reduce(0, +) == 1_999_999_999_999_999_999)
        #expect(Array(quintillion.suffix(3)) == [288_230_376_151_711_744, 576_460_752_303_423_488, 847_078_495_393_153_024])

        let power = RecursionTreeLevels.halvesLevels(1 << 60)
        #expect(power == (0...60).map { 1 << $0 })

        let threeQuarters = RecursionTreeLevels.halvesLevels(3 << 58)
        #expect(threeQuarters.count == 61)
        #expect(threeQuarters.reduce(0, +) == (6 << 58) - 1)
    }
}
