import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RegexLiteRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct RegexLiteMatcherTests {
    /// Plain recursion: does t[i...] match p[j...]? Exponential with many stars, fine when short.
    private func brute(_ t: [Character], _ p: [Character], _ i: Int, _ j: Int) -> Bool {
        if j == p.count { return i == t.count }
        let first = i < t.count && (p[j] == "." || p[j] == t[i])
        if j + 1 < p.count && p[j + 1] == "*" {
            return brute(t, p, i, j + 2) || (first && brute(t, p, i + 1, j))
        }
        return first && brute(t, p, i + 1, j + 1)
    }

    @Test("Examples", arguments: [
        ("colour", "colou*r", true),
        ("color", "colou*r", true),
        ("colouur", "colou*r", true),
        ("swift", "s.*t", true),
        ("swift", "s.ift", true),
        ("swift", "s.ft", false),
        ("aab", "c*a*b", true),
    ])
    func examples(text: String, pattern: String, expected: Bool) {
        #expect(RegexLiteMatcher.matches(text, pattern: pattern) == expected)
    }

    @Test("Empty strings and the star cases", arguments: [
        ("", "", true),
        ("a", "", false),
        ("", "a", false),
        ("", ".", false),
        ("", "a*", true),
        ("", "a*b*.*", true),
        ("", "a*b", false),
        ("ab", ".*", true),
        ("ab", ".*c", false),
        ("aaa", "a*a", true),
        ("aaa", "a*aaaa", false),
        ("aaa", "ab*a*c*a", true),
        ("a", ".*..", false),
        ("a", "ab*", true),
        ("aa", "a", false),
        ("abcd", "d*", false),
        ("bbbba", ".*a*a", true),
        ("ab", "a.b", false),
        ("xyz", ".*.*.*", true),
    ])
    func edges(text: String, pattern: String, expected: Bool) {
        #expect(RegexLiteMatcher.matches(text, pattern: pattern) == expected)
    }

    @Test("Matches plain recursion on 2,000 random short cases")
    func randomSmall() {
        var random = RegexLiteRandom(seed: 548)
        let tokens = ["a", "b", ".", "a*", "b*", ".*"]
        for _ in 0..<2_000 {
            let text = String((0..<Int.random(in: 0...7, using: &random)).map { _ in Int.random(in: 0..<2, using: &random) == 0 ? Character("a") : Character("b") })
            let pattern = (0..<Int.random(in: 0...5, using: &random)).map { _ in tokens[Int.random(in: 0..<tokens.count, using: &random)] }.joined()
            #expect(RegexLiteMatcher.matches(text, pattern: pattern) == brute(Array(text), Array(pattern), 0, 0),
                    "\"\(text)\" against \"\(pattern)\"")
        }
    }

    @Test("Long texts that make plain recursion explode")
    func long() {
        let manyA = String(repeating: "a", count: 700)
        #expect(!RegexLiteMatcher.matches(manyA, pattern: "a*a*a*a*a*a*b"))
        #expect(RegexLiteMatcher.matches(manyA + "b", pattern: "a*a*a*a*a*a*b"))
        #expect(!RegexLiteMatcher.matches(manyA, pattern: ".*a.*a.*a.*a.*c"))
        #expect(RegexLiteMatcher.matches(manyA + "c", pattern: ".*a.*a.*a.*a.*c"))
        #expect(RegexLiteMatcher.matches(manyA + "b", pattern: String(repeating: "a*", count: 120) + "b"))
        #expect(!RegexLiteMatcher.matches(manyA, pattern: String(repeating: "a*", count: 120) + "b"))
        #expect(RegexLiteMatcher.matches(manyA, pattern: String(repeating: "a", count: 200) + ".*" + String(repeating: "a", count: 40)))
        #expect(!RegexLiteMatcher.matches(String(repeating: "a", count: 239), pattern: String(repeating: ".", count: 240)))
    }
}
