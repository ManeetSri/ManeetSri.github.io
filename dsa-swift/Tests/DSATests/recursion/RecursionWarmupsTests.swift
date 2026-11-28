import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RecursionWarmupsTests {
    @Test("Bounces down to 0 and back up", arguments: [
        (0, [0]),
        (1, [1, 0, 1]),
        (2, [2, 1, 0, 1, 2]),
        (4, [4, 3, 2, 1, 0, 1, 2, 3, 4]),
    ])
    func bounce(n: Int, expected: [Int]) {
        #expect(RecursionWarmups.bounce(from: n) == expected)
    }

    @Test("A long bounce has the right shape")
    func longBounce() throws {
        let result = RecursionWarmups.bounce(from: 500)
        try #require(result.count == 1_001)
        #expect(result.first == 500)
        #expect(result[500] == 0)
        #expect(result.last == 500)
        #expect(result == Array(stride(from: 500, through: 0, by: -1)) + Array(1...500))
    }

    @Test("Raises to a power", arguments: [
        (2, 0, 1),
        (2, 1, 2),
        (2, 10, 1_024),
        (3, 13, 1_594_323),
        (10, 18, 1_000_000_000_000_000_000),
        (7, 1, 7),
        (5, 0, 1),
        (0, 0, 1),
        (0, 5, 0),
    ])
    func power(base: Int, exponent: Int, expected: Int) {
        #expect(RecursionWarmups.power(base, exponent) == expected)
    }

    @Test("Handles negative bases")
    func negativeBases() {
        #expect(RecursionWarmups.power(-2, 3) == -8)
        #expect(RecursionWarmups.power(-2, 4) == 16)
        #expect(RecursionWarmups.power(-1, 999) == -1)
        #expect(RecursionWarmups.power(-1, 1_000) == 1)
    }

    @Test("Reaches the edge of Int")
    func largePowers() {
        #expect(RecursionWarmups.power(2, 62) == 4_611_686_018_427_387_904)
        #expect(RecursionWarmups.power(1, 1_000) == 1)
        #expect(RecursionWarmups.power(-3, 39) == -4_052_555_153_018_976_267)
    }

    @Test("Counts a character", arguments: [
        ("banana", "a" as Character, 3),
        ("banana", "n" as Character, 2),
        ("banana", "z" as Character, 0),
        ("", "a" as Character, 0),
        ("a", "a" as Character, 1),
        ("Swift", "s" as Character, 0),
        ("café crème", "é" as Character, 1),
        ("aaaa", "a" as Character, 4),
    ])
    func count(text: String, character: Character, expected: Int) {
        #expect(RecursionWarmups.count(of: character, in: text) == expected)
    }

    @Test("Counts in a 1,000-character string")
    func longText() {
        let text = String(repeating: "ab", count: 500)
        #expect(RecursionWarmups.count(of: "a", in: text) == 500)
        #expect(RecursionWarmups.count(of: "b", in: text) == 500)
    }
}
