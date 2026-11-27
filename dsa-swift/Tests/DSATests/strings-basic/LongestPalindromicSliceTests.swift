import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LongestPalindromicSliceTests {
    @Test("Finds the longest palindromic substring", arguments: [
        ("abracadabra", "aca"),
        ("noonday", "noon"),
        ("12321abc", "12321"),
        ("level99", "level"),
        ("banana", "anana"),
        ("abcddcbz", "bcddcb"),
        ("ab1ba", "ab1ba"),
        ("cabbad", "abba"),
        ("abaab", "baab"),
        ("x", "x"),
        ("ab", "a"),
        ("", ""),
    ])
    func examples(text: String, expected: String) {
        #expect(LongestPalindromicSlice.longest(in: text) == expected)
    }

    @Test("Matches a brute force on many small strings")
    func matchesBruteForce() {
        let alphabet = Array("ab1")
        var firstMismatch: String? = nil
        for seed in 0..<300 {
            let chars = (0..<(seed % 11)).map { alphabet[($0 * $0 + seed * 7 + $0 / 4) % 3] }
            var expected = ""
            for start in chars.indices {
                for end in start..<chars.count {
                    let piece = Array(chars[start...end])
                    if piece == piece.reversed() && piece.count > expected.count {
                        expected = String(piece)
                    }
                }
            }
            if LongestPalindromicSlice.longest(in: String(chars)) != expected {
                firstMismatch = firstMismatch ?? String(chars)
            }
        }
        #expect(firstMismatch == nil, "the first string where the answer differs from the brute force")
    }

    @Test("Stays fast on 2,000 characters")
    func large() {
        let same = String(repeating: "a", count: 2_000)
        #expect(LongestPalindromicSlice.longest(in: same) == same)

        // "abab...ab": the longest palindrome drops the last character
        let alternating = String(repeating: "ab", count: 1_000)
        #expect(LongestPalindromicSlice.longest(in: alternating) == String(alternating.dropLast()))

        // A palindrome hidden in the middle of text with no other repeats nearby
        let digits = Array("0123456789")
        let noise = String((0..<995).map { digits[$0 % 10] })
        let hidden = noise + "racecar" + noise
        #expect(LongestPalindromicSlice.longest(in: hidden) == "racecar")
    }
}
