import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct WarmerDayWaitTests {
    @Test("Counts the days to wait", arguments: [
        ([15, 17, 16, 14, 18, 13], [1, 3, 2, 1, 0, 0]),
        ([10, 20, 30], [1, 1, 0]),
        ([30, 20, 10], [0, 0, 0]),
        ([21, 21, 22], [2, 1, 0]),
        ([5], [0]),
        ([-3, -8, -1, -5, 0], [2, 1, 2, 1, 0]),
    ])
    func waits(temperatures: [Int], expected: [Int]) {
        #expect(WarmerDayWait.daysToWait(temperatures) == expected)
    }

    @Test("No days, no waits")
    func empty() {
        #expect(WarmerDayWait.daysToWait([]) == [])
    }

    @Test("Equal temperatures don't count as warmer")
    func equalNotWarmer() {
        #expect(WarmerDayWait.daysToWait([18, 18, 18]) == [0, 0, 0])
        #expect(WarmerDayWait.daysToWait([18, 18, 19]) == [2, 1, 0])
    }

    @Test("Matches a brute force on many small inputs")
    func matchesBruteForce() {
        func bruteForce(_ temperatures: [Int]) -> [Int] {
            temperatures.indices.map { day in
                let later = temperatures.indices.dropFirst(day + 1)
                return later.first { temperatures[$0] > temperatures[day] }.map { $0 - day } ?? 0
            }
        }
        var mismatches = 0
        for seed in 0..<300 {
            let temperatures = (0..<(seed % 13)).map { ($0 * 7 + seed * 11) % 9 + 10 }
            if WarmerDayWait.daysToWait(temperatures) != bruteForce(temperatures) {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays fast on 100,000 days that keep getting colder until the last")
    func large() throws {
        var temperatures = Array((1...99_999).reversed())
        temperatures.append(100_000)
        let waits = WarmerDayWait.daysToWait(temperatures)
        try #require(waits.count == 100_000)
        #expect(waits[0] == 99_999)
        #expect(waits[50_000] == 49_999)
        #expect(waits[99_998] == 1)
        #expect(waits[99_999] == 0)
    }
}
