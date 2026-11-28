import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GrowthCopiesTests {
    // Simulates every append; copies[n] is the total after n appends
    static func simulatedCopies(upTo maxAppends: Int, grow: (Int) -> Int) -> [Int] {
        var capacity = 1
        var copied = 0
        var totals = [0]
        for count in 0..<maxAppends {
            if count == capacity {
                copied += count
                capacity = grow(capacity)
            }
            totals.append(copied)
        }
        return totals
    }

    @Test("Doubling examples", arguments: [(0, 0), (1, 0), (2, 1), (3, 3), (5, 7), (10, 15), (1_000, 1_023)])
    func doublingExamples(appends: Int, expected: Int) {
        #expect(GrowthCopies.copiesWhenDoubling(appends: appends) == expected)
    }

    @Test("Doubling matches a simulation for every n up to 5,000")
    func doublingMatchesSimulation() {
        let totals = Self.simulatedCopies(upTo: 5_000) { $0 * 2 }
        let wrong = (0...5_000).filter { GrowthCopies.copiesWhenDoubling(appends: $0) != totals[$0] }
        #expect(wrong.isEmpty, "wrong for n = \(Array(wrong.prefix(5)))")
    }

    @Test("Doubling stays under 2n copies, even for huge n")
    func doublingHuge() {
        #expect(GrowthCopies.copiesWhenDoubling(appends: 1_000_000_000) == 1_073_741_823)
        #expect(GrowthCopies.copiesWhenDoubling(appends: 1_000_000_000_000_000_000) == 1_152_921_504_606_846_975)
    }

    @Test("Fixed-step examples", arguments: [(10, 1_000, 49_600), (1, 5, 10), (3, 8, 12), (5, 1, 0), (5, 2, 1), (100, 101, 1)])
    func fixedStepExamples(step: Int, appends: Int, expected: Int) {
        #expect(GrowthCopies.copiesWhenGrowing(by: step, appends: appends) == expected)
    }

    @Test("Fixed step matches a simulation for every n up to 2,000", arguments: [1, 2, 3, 7, 10, 64, 1_999, 5_000])
    func fixedStepMatchesSimulation(step: Int) {
        let totals = Self.simulatedCopies(upTo: 2_000) { $0 + step }
        let wrong = (0...2_000).filter { GrowthCopies.copiesWhenGrowing(by: step, appends: $0) != totals[$0] }
        #expect(wrong.isEmpty, "step \(step): wrong for n = \(Array(wrong.prefix(5)))")
    }

    @Test("Fixed step for a billion appends, in O(1)")
    func fixedStepHuge() {
        #expect(GrowthCopies.copiesWhenGrowing(by: 1, appends: 1_000_000_000) == 499_999_999_500_000_000)
        #expect(GrowthCopies.copiesWhenGrowing(by: 1_000, appends: 1_000_000_000) == 499_999_501_000_000)
        #expect(GrowthCopies.copiesWhenGrowing(by: 7, appends: 123_456_789) == 1_088_684_134_713_786)
        #expect(GrowthCopies.copiesWhenGrowing(by: 1_000_000_000, appends: 1_000_000_000) == 1)
    }
}
