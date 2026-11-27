import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct VolunteerRosterTests {
    /// Calls the function with plain (first, last, people) triples.
    private static func roster(_ days: Int, _ pledges: [(Int, Int, Int)]) -> [Int] {
        VolunteerRoster.volunteersPerDay(days: days, pledges: pledges.map { (first: $0.0, last: $0.1, people: $0.2) })
    }

    @Test("Adds up the pledges for each day")
    func examples() {
        #expect(Self.roster(5, [(1, 3, 4), (2, 5, 1), (4, 4, 10)]) == [4, 5, 5, 11, 1])
        #expect(Self.roster(6, [(2, 4, 5), (3, 6, 2), (1, 2, 10)]) == [10, 15, 7, 7, 2, 2])
        #expect(Self.roster(3, [(1, 3, 7)]) == [7, 7, 7])
    }

    @Test("Pledges on the first and last day")
    func edges() {
        #expect(Self.roster(4, [(1, 1, 3)]) == [3, 0, 0, 0])
        #expect(Self.roster(4, [(4, 4, 3)]) == [0, 0, 0, 3])
        #expect(Self.roster(1, [(1, 1, 2), (1, 1, 5)]) == [7])
    }

    @Test("No pledges means no volunteers")
    func noPledges() {
        #expect(Self.roster(3, []) == [0, 0, 0])
    }

    @Test("Matches adding to every day on many small rosters")
    func matchesBruteForce() {
        var mismatches = 0
        for seed in 0..<100 {
            let days = seed % 9 + 1
            let pledges = (0..<(seed % 6)).map { index -> (Int, Int, Int) in
                let a = (index * 7 + seed) % days + 1
                let b = (index * 3 + seed * 5) % days + 1
                return (min(a, b), max(a, b), index + seed % 4 + 1)
            }
            var expected = Array(repeating: 0, count: days)
            for (first, last, people) in pledges {
                for day in first...last {
                    expected[day - 1] += people
                }
            }
            if Self.roster(days, pledges) != expected {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays fast with 100,000 pledges over 100,000 days")
    func large() {
        let days = 100_000
        let everyDay = (1...100_000).map { (1, days, $0 % 10 + 1) }
        let total = everyDay.reduce(0) { $0 + $1.2 }
        #expect(Self.roster(days, everyDay) == Array(repeating: total, count: days))

        // Pledge i covers days i...days, so day d gets one volunteer from each of pledges 1...d
        let growing = (1...days).map { ($0, days, 1) }
        #expect(Self.roster(days, growing) == Array(1...days))
    }
}
