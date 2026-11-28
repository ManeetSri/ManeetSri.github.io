import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TwoWayMappingTests {
    @Test("Recognises isomorphic strings", arguments: [
        ("paper", "title", true),
        ("noon", "deed", true),
        ("ab", "cc", false),
        ("cc", "ab", false),
        ("abc", "xyz", true),
        ("abca", "zbxz", true),
        ("abca", "zbxy", false),
        ("", "", true),
        ("a", "ab", false),
        ("13", "42", true),
    ])
    func isomorphic(first: String, second: String, expected: Bool) {
        #expect(TwoWayMapping.isomorphic(first, second) == expected)
    }

    @Test("Checks a sentence against a pattern", arguments: [
        ("xyyx", "sun moon moon sun", true),
        ("xyyx", "sun moon moon star", false),
        ("xx", "sun moon", false),
        ("xy", "sun sun", false),
        ("xyz", "red green", false),
        ("x", "hello", true),
        ("abcab", "one two three one two", true),
        ("aaaa", "go go go go", true),
        ("ab", "go go go", false),
    ])
    func pattern(pattern: String, sentence: String, expected: Bool) {
        #expect(TwoWayMapping.followsPattern(pattern, sentence) == expected)
    }

    @Test("Stays fast on 100,000 characters")
    func large() {
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        let first = String((0..<100_000).map { letters[($0 * 7) % 26] })
        let second = String((0..<100_000).map { letters[($0 * 7 + 3) % 26] })
        #expect(TwoWayMapping.isomorphic(first, second))
        #expect(!TwoWayMapping.isomorphic(first, String(second.dropLast()) + "a"))

        let words = (0..<20_000).map { "w\($0 % 26)" }.joined(separator: " ")
        let pattern = String((0..<20_000).map { letters[$0 % 26] })
        #expect(TwoWayMapping.followsPattern(pattern, words))
    }
}
