import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct SkillRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct DisjointSkillPairsTests {
    /// Brute force: check every pair
    private func bruteForce(_ skills: [Int]) -> Int {
        var pairs = 0
        for i in skills.indices {
            for j in skills.indices where j > i && skills[i] & skills[j] == 0 {
                pairs += 1
            }
        }
        return pairs
    }

    @Test("Examples and small cases", arguments: [
        ([0b011, 0b100, 0b110, 0b001], 3, 3),
        ([0, 0, 0], 2, 3),
        ([1, 1, 1], 1, 0),
        ([5], 3, 0),
        ([], 4, 0),
        ([0b1010, 0b0101, 0b1111, 0b0000], 4, 4),
    ] as [([Int], Int, Int)])
    func examples(skills: [Int], skillCount: Int, expected: Int) {
        #expect(DisjointSkillPairs.countPairs(skills, skillCount: skillCount) == expected)
    }

    @Test("Matches checking every pair on 300 random groups")
    func randomSmall() {
        var random = SkillRandom(seed: 58)
        for _ in 0..<300 {
            let skillCount = Int.random(in: 1...10, using: &random)
            // Sparse masks make disjoint pairs common enough to matter
            let skills = (0..<Int.random(in: 0...60, using: &random)).map { _ in
                Int.random(in: 0..<(1 << skillCount), using: &random) & Int.random(in: 0..<(1 << skillCount), using: &random)
            }
            #expect(DisjointSkillPairs.countPairs(skills, skillCount: skillCount) == bruteForce(skills))
        }
    }

    @Test("100,000 volunteers over 16 skills")
    func large() {
        // The volunteers share 300 distinct skill sets, so the expected answer can be found from the
        // 300 × 300 table of distinct sets, while a solution still sees 100,000 volunteers
        var random = SkillRandom(seed: 2_058)
        let skillCount = 16
        let kinds = (0..<300).map { _ in
            Int.random(in: 0..<(1 << skillCount), using: &random) & Int.random(in: 0..<(1 << skillCount), using: &random)
                & Int.random(in: 0..<(1 << skillCount), using: &random)
        }
        let skills = (0..<100_000).map { _ in kinds[Int.random(in: 0..<300, using: &random)] }
        var multiplicity: [Int: Int] = [:]
        for x in skills { multiplicity[x, default: 0] += 1 }
        let distinct = multiplicity.keys.sorted()
        var expected = 0
        for (a, x) in distinct.enumerated() {
            let cx = multiplicity[x]!
            if x == 0 { expected += cx * (cx - 1) / 2 }
            for y in distinct[(a + 1)...] where x & y == 0 {
                expected += cx * multiplicity[y]!
            }
        }
        #expect(DisjointSkillPairs.countPairs(skills, skillCount: skillCount) == expected)
    }

    @Test("Sixteen skills: single skills, no skills and everything")
    func extremes() {
        let singles = (0..<100_000).map { 1 << ($0 % 16) }      // 6,250 volunteers with each skill
        #expect(DisjointSkillPairs.countPairs(singles, skillCount: 16) == 120 * 6_250 * 6_250)
        let nobody = [Int](repeating: 0, count: 50_000)
        #expect(DisjointSkillPairs.countPairs(nobody, skillCount: 16) == 50_000 * 49_999 / 2)
        let everything = [Int](repeating: (1 << 16) - 1, count: 1_000) + [0, 0]
        #expect(DisjointSkillPairs.countPairs(everything, skillCount: 16) == 2 * 1_000 + 1)
    }
}
