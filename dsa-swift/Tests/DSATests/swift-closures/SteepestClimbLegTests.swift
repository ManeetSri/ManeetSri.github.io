import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SteepestClimbLegTests {
    @Test("Finds the biggest climb", arguments: [
        ([100, 140, 130, 190, 200], 2, 60),
        ([-20, -5], 0, 15),
        ([1, 2, 3, 4, 10], 3, 6),
        ([50, 10, 20, 0, 5], 1, 10),
        ([0, 1_000_000, -1_000_000, 1_000_000], 2, 2_000_000),
    ])
    func finds(altitudes: [Int], start: Int, rise: Int) throws {
        let leg = try #require(SteepestClimbLeg.steepestClimb(in: altitudes))
        #expect(leg.start == start)
        #expect(leg.rise == rise)
    }

    @Test("Ties go to the earliest leg", arguments: [
        ([5, 9, 1, 5], 0, 4),
        ([0, 3, 3, 6, 6, 9], 0, 3),
        ([10, 8, 12, 8, 12], 1, 4),
    ])
    func ties(altitudes: [Int], start: Int, rise: Int) throws {
        let leg = try #require(SteepestClimbLeg.steepestClimb(in: altitudes))
        #expect(leg.start == start)
        #expect(leg.rise == rise)
    }

    @Test("Level and downhill legs aren't climbs", arguments: [
        [9, 7, 7, 3],
        [4, 4, 4],
        [10, 0, -10],
    ])
    func noClimb(altitudes: [Int]) {
        #expect(SteepestClimbLeg.steepestClimb(in: altitudes) == nil)
    }

    @Test("Fewer than two checkpoints means no legs", arguments: [[Int](), [42]])
    func tooShort(altitudes: [Int]) {
        #expect(SteepestClimbLeg.steepestClimb(in: altitudes) == nil)
    }

    @Test("A small climb after big drops still counts")
    func smallClimb() throws {
        let leg = try #require(SteepestClimbLeg.steepestClimb(in: [100, 0, -100, -99, -500]))
        #expect(leg.start == 2)
        #expect(leg.rise == 1)
    }

    @Test("Stays fast on 100,000 checkpoints")
    func large() throws {
        let altitudes = (0..<100_000).map { ($0 * 7_919) % 10_007 }
        var bestStart = -1
        var bestRise = 0
        for i in 1..<altitudes.count where altitudes[i] - altitudes[i - 1] > bestRise {
            bestRise = altitudes[i] - altitudes[i - 1]
            bestStart = i - 1
        }
        let leg = try #require(SteepestClimbLeg.steepestClimb(in: altitudes))
        #expect(leg.start == bestStart)
        #expect(leg.rise == bestRise)
    }
}
