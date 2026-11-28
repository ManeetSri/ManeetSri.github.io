import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CooldownSchedulerTests {
    /// The closed form: the busiest kinds set the length, unless there are enough jobs to fill every gap.
    private func formula(_ jobs: [String], cooldown: Int) -> Int {
        let counts = Dictionary(jobs.map { ($0, 1) }, uniquingKeysWith: +).values
        guard let most = counts.max() else { return 0 }
        let busiest = counts.filter { $0 == most }.count
        return max(jobs.count, (most - 1) * (cooldown + 1) + busiest)
    }

    private func jobs(_ text: String) -> [String] {
        text.map { String($0) }
    }

    @Test("Small cases", arguments: [
        ("AAABBB", 2, 8),
        ("AAABBB", 0, 6),
        ("AAAABC", 2, 10),
        ("ABCDEF", 3, 6),
        ("AAABBBCCD", 2, 9),
        ("A", 5, 1),
        ("AA", 5, 7),
        ("", 3, 0),
    ])
    func small(text: String, cooldown: Int, expected: Int) {
        #expect(CooldownScheduler.fewestSlots(jobs(text), cooldown: cooldown) == expected)
    }

    @Test("Kinds can be any names")
    func names() {
        let print = ["report", "photo", "report", "invoice", "report"]
        #expect(CooldownScheduler.fewestSlots(print, cooldown: 1) == 5)
        #expect(CooldownScheduler.fewestSlots(print, cooldown: 2) == 7)
    }

    @Test("Agrees with the closed form on hundreds of inputs")
    func matchesFormula() {
        var mismatches = 0
        for seed in 1...300 {
            let kinds = 1 + seed % 6
            let list = (0..<(seed % 30)).map { "k\(($0 * $0 + seed * 7) % kinds)" }
            let cooldown = seed % 5
            if CooldownScheduler.fewestSlots(list, cooldown: cooldown) != formula(list, cooldown: cooldown) {
                mismatches += 1
            }
        }
        #expect(mismatches == 0)
    }

    @Test("100,000 jobs", arguments: [(26, 0), (26, 3), (26, 50), (1_000, 100), (1, 100), (100_000, 100)])
    func large(kinds: Int, cooldown: Int) {
        let list = (0..<100_000).map { "j\(($0 * 7_919) % kinds)" }
        #expect(CooldownScheduler.fewestSlots(list, cooldown: cooldown) == formula(list, cooldown: cooldown))
    }
}
