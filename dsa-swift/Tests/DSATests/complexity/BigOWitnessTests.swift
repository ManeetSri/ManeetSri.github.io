import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct BigOWitnessTests {
    // The smallest n₀ found by checking every n up to `limit`: one past the last n where the
    // inequality fails, or nil if it still fails at `limit`
    static func scannedStart(limit: Int, holds: (Int) -> Bool) -> Int? {
        if !holds(limit) { return nil }
        var lastFailure = 0
        for n in 1...limit where !holds(n) {
            lastFailure = n
        }
        return lastFailure + 1
    }

    @Test("Linear examples", arguments: [
        (3, 2, 4, 2 as Int?), (2, 100, 3, 100), (3, 2, 10, 1), (3, 2, 3, nil),
        (5, 0, 5, 1), (5, 1, 5, nil), (6, 0, 2, nil), (1, 0, 9, 1), (1, 7, 3, 4),
    ])
    func linearExamples(a: Int, b: Int, c: Int, expected: Int?) {
        #expect(BigOWitness.linearStart(a: a, b: b, c: c) == expected)
    }

    @Test("Linear matches a scan for every small a, b and c")
    func linearMatchesScan() {
        var wrong: [String] = []
        for a in 1...6 {
            for b in 0...40 {
                for c in 1...8 {
                    let expected = Self.scannedStart(limit: 200) { a * $0 + b <= c * $0 }
                    if BigOWitness.linearStart(a: a, b: b, c: c) != expected {
                        wrong.append("a \(a), b \(b), c \(c)")
                    }
                }
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
    }

    @Test("Linear with a huge b, without trying every n")
    func linearHuge() {
        #expect(BigOWitness.linearStart(a: 1, b: 1_000_000_000_000_000_000, c: 2) == 1_000_000_000_000_000_000)
        #expect(BigOWitness.linearStart(a: 7, b: 999_999_999_999_999_999, c: 10) == 333_333_333_333_333_333)
        #expect(BigOWitness.linearStart(a: 3, b: 1_000_000_000_000_000_000, c: 10) == 142_857_142_857_142_858)
        #expect(BigOWitness.linearStart(a: 1, b: 1_000_000_000_000_000_000, c: 1_000_000) == 1_000_001_000_002)
    }

    @Test("Quadratic examples", arguments: [
        (1, 10, 0, 2, 10 as Int?), (2, 3, 5, 3, 5), (4, 0, 0, 1, nil), (1, 10, 0, 1, nil),
        (1, 0, 100, 2, 10), (3, 0, 0, 3, 1), (3, 0, 1, 3, nil), (1, 0, 0, 2, 1), (2, 1, 1, 5, 1),
    ])
    func quadraticExamples(a: Int, b: Int, k: Int, c: Int, expected: Int?) {
        #expect(BigOWitness.quadraticStart(a: a, b: b, k: k, c: c) == expected)
    }

    @Test("Quadratic matches a scan for small coefficients")
    func quadraticMatchesScan() {
        var wrong: [String] = []
        for a in 1...4 {
            for b in stride(from: 0, through: 60, by: 3) {
                for k in stride(from: 0, through: 90, by: 9) {
                    for c in 1...6 {
                        let expected = Self.scannedStart(limit: 300) { a * $0 * $0 + b * $0 + k <= c * $0 * $0 }
                        if BigOWitness.quadraticStart(a: a, b: b, k: k, c: c) != expected {
                            wrong.append("a \(a), b \(b), k \(k), c \(c)")
                        }
                    }
                }
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
    }

    @Test("Quadratic at the largest coefficients")
    func quadraticLarge() {
        #expect(BigOWitness.quadraticStart(a: 1, b: 1_000_000, k: 1_000_000, c: 2) == 1_000_001)
        #expect(BigOWitness.quadraticStart(a: 999, b: 1_000_000, k: 1_000_000, c: 1_000) == 1_000_001)
        #expect(BigOWitness.quadraticStart(a: 1, b: 0, k: 1_000_000, c: 1_000) == 32)
    }
}
