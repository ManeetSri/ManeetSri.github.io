import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct HailstoneSequenceTests {
    typealias Hailstone = HailstoneSequence.Hailstone

    @Test("Produces the hailstone numbers")
    func values() {
        #expect(Array(Hailstone(start: 6)) == [6, 3, 10, 5, 16, 8, 4, 2, 1])
        #expect(Array(Hailstone(start: 7)) == [7, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1])
        #expect(Array(Hailstone(start: 2)) == [2, 1])
    }

    @Test("Starting at 1 gives just 1")
    func startAtOne() {
        #expect(Array(Hailstone(start: 1)) == [1])
    }

    @Test("Works in a for-in loop")
    func forIn() {
        var seen: [Int] = []
        for value in Hailstone(start: 3) {
            seen.append(value)
        }
        #expect(seen == [3, 10, 5, 16, 8, 4, 2, 1])
    }

    @Test("Can be looped over more than once")
    func reusable() {
        let sequence = Hailstone(start: 12)
        #expect(Array(sequence) == Array(sequence))
        #expect(sequence.start == 12)
    }

    @Test("Gets Sequence abilities for free")
    func freeAbilities() {
        let sequence = Hailstone(start: 6)
        #expect(sequence.contains(16))
        #expect(!sequence.contains(7))
        #expect(Array(sequence.prefix(3)) == [6, 3, 10])
        #expect(sequence.filter { $0.isMultiple(of: 2) } == [6, 10, 16, 8, 4, 2])
    }

    @Test("Counts the steps down to 1", arguments: [(1, 0), (2, 1), (3, 7), (6, 8), (7, 16), (27, 111), (97, 118), (871, 178)])
    func steps(start: Int, expected: Int) {
        #expect(HailstoneSequence.stepsToOne(from: start) == expected)
    }

    @Test("Finds the peak", arguments: [(1, 1), (6, 16), (7, 52), (27, 9_232), (871, 190_996), (1_000_000, 1_000_000)])
    func peak(start: Int, expected: Int) {
        #expect(HailstoneSequence.peak(from: start) == expected)
    }

    @Test("Handles long sequences and huge peaks")
    func large() {
        #expect(HailstoneSequence.stepsToOne(from: 837_799) == 524)
        #expect(HailstoneSequence.peak(from: 837_799) == 2_974_984_576)
        #expect(HailstoneSequence.peak(from: 704_511) == 56_991_483_520)
    }
}
