import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LoopStepCountTests {
    // The loops from the statement, run for real, to check small n
    static func countedPairChecks(_ n: Int) -> Int {
        var steps = 0
        for i in 0..<n {
            for _ in (i + 1)..<n {
                steps += 1
            }
        }
        return steps
    }

    static func countedShrinkingPasses(_ n: Int) -> Int {
        var steps = 0
        var size = n
        while size > 0 {
            for _ in 0..<size {
                steps += 1
            }
            size /= 2
        }
        return steps
    }

    @Test("Pair checks for the examples", arguments: [(0, 0), (1, 0), (2, 1), (3, 3), (5, 10), (10, 45)])
    func pairExamples(n: Int, expected: Int) {
        #expect(LoopStepCount.pairChecks(n) == expected)
    }

    @Test("Pair checks match the real loops for every n up to 200")
    func pairsMatchLoops() {
        let wrong = (0...200).filter { LoopStepCount.pairChecks($0) != Self.countedPairChecks($0) }
        #expect(wrong.isEmpty, "wrong for n = \(Array(wrong.prefix(5)))")
    }

    @Test("Pair checks for huge n, without looping")
    func pairsHuge() {
        #expect(LoopStepCount.pairChecks(100_000) == 4_999_950_000)
        #expect(LoopStepCount.pairChecks(1_000_000_000) == 499_999_999_500_000_000)
    }

    @Test("Shrinking passes for the examples", arguments: [(0, 0), (1, 1), (2, 3), (3, 4), (10, 18), (1_000, 1_994)])
    func shrinkingExamples(n: Int, expected: Int) {
        #expect(LoopStepCount.shrinkingPasses(n) == expected)
    }

    @Test("Shrinking passes match the real loops for every n up to 3,000")
    func shrinkingMatchesLoops() {
        let wrong = (0...3_000).filter { LoopStepCount.shrinkingPasses($0) != Self.countedShrinkingPasses($0) }
        #expect(wrong.isEmpty, "wrong for n = \(Array(wrong.prefix(5)))")
    }

    @Test("Shrinking passes for n near 10¹⁸, without running the body")
    func shrinkingHuge() {
        #expect(LoopStepCount.shrinkingPasses(1_000_000_000_000_000_000) == 1_999_999_999_999_999_976)
        #expect(LoopStepCount.shrinkingPasses(999_999_999_999_999_999) == 1_999_999_999_999_999_957)
    }
}
