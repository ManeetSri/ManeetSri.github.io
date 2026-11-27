import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct WildcardRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct WildcardPatternMatcherTests {
    /// Plain recursion: does t[i...] match p[j...]? Exponential with many stars, fine when short.
    private func brute(_ t: [Character], _ p: [Character], _ i: Int, _ j: Int) -> Bool {
        if j == p.count { return i == t.count }
        if p[j] == "*" {
            return brute(t, p, i, j + 1) || (i < t.count && brute(t, p, i + 1, j))
        }
        return i < t.count && (p[j] == "?" || p[j] == t[i]) && brute(t, p, i + 1, j + 1)
    }

    private func randomText(_ alphabet: [Character], _ length: Int, _ random: inout WildcardRandom) -> String {
        String((0..<length).map { _ in alphabet[Int.random(in: 0..<alphabet.count, using: &random)] })
    }

    @Test("Examples", arguments: [
        ("report.swift", "*.swift", true),
        ("report.swift", "*.sw?ft", true),
        ("report.swift", "r*t", true),
        ("report.swift", "*.md", false),
        ("swiftly", "s*y", true),
        ("swiftly", "s*t", false),
        ("abcb", "*?b", true),
    ])
    func examples(text: String, pattern: String, expected: Bool) {
        #expect(WildcardPatternMatcher.matches(text, pattern: pattern) == expected)
    }

    @Test("Empty text, empty pattern and stars", arguments: [
        ("", "", true),
        ("", "*", true),
        ("", "***", true),
        ("", "?", false),
        ("", "*?*", false),
        ("a", "", false),
        ("abc", "a**c", true),
        ("abc", "*", true),
        ("abc", "**c", true),
        ("abc", "*?*?*?*", true),
        ("ab", "*?*?*?*", false),
        ("x", "*x*", true),
        ("aa", "a", false),
        ("a", "aa", false),
        ("abc", "a?", false),
        ("cb", "?a", false),
        ("mama", "*ma", true),
        ("mamb", "*ma", false),
    ])
    func edges(text: String, pattern: String, expected: Bool) {
        #expect(WildcardPatternMatcher.matches(text, pattern: pattern) == expected)
    }

    @Test("Matches plain recursion on 2,000 random short cases")
    func randomSmall() {
        var random = WildcardRandom(seed: 547)
        for _ in 0..<2_000 {
            let text = randomText(Array("ab"), Int.random(in: 0...6, using: &random), &random)
            let pattern = randomText(Array("ab?*"), Int.random(in: 0...6, using: &random), &random)
            #expect(WildcardPatternMatcher.matches(text, pattern: pattern) == brute(Array(text), Array(pattern), 0, 0),
                    "\"\(text)\" against \"\(pattern)\"")
        }
    }

    @Test("Long texts that make plain recursion explode")
    func long() {
        let manyA = String(repeating: "a", count: 700)
        #expect(!WildcardPatternMatcher.matches(manyA, pattern: "*a*a*a*a*a*a*b"))
        #expect(WildcardPatternMatcher.matches(manyA + "b", pattern: "*a*a*a*a*a*a*b"))
        #expect(WildcardPatternMatcher.matches(manyA, pattern: String(repeating: "?*", count: 120)))
        #expect(!WildcardPatternMatcher.matches(manyA, pattern: String(repeating: "*a", count: 120) + "?*c"))
        #expect(WildcardPatternMatcher.matches(manyA, pattern: String(repeating: "*", count: 250)))
        #expect(!WildcardPatternMatcher.matches(String(repeating: "a", count: 239), pattern: String(repeating: "?*", count: 240)))
    }

    @Test("A long file name against long patterns")
    func longRandom() {
        var random = WildcardRandom(seed: 7_000)
        let text = randomText(Array("abc"), 700, &random)
        let characters = Array(text)
        // Keep every tenth character, and put a star in each gap: it must match
        var pattern = "*"
        for index in stride(from: 0, to: characters.count, by: 10) {
            pattern += String(characters[index]) + "*"
        }
        #expect(WildcardPatternMatcher.matches(text, pattern: pattern))
        // A character that isn't in the text can't be matched by anything but '?'
        #expect(!WildcardPatternMatcher.matches(text, pattern: pattern + "d"))
        #expect(WildcardPatternMatcher.matches(text, pattern: pattern + "?"))
        #expect(WildcardPatternMatcher.matches(text, pattern: String(characters.prefix(200)) + "*" + String(characters.suffix(200))))
    }
}
