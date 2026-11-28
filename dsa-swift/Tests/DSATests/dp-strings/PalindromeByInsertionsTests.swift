import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct PalindromeInsertRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct PalindromeByInsertionsTests {
    /// Checks every subsequence: 2ⁿ of them, fine for short strings
    private func bruteLongest(_ text: String) -> Int {
        let s = Array(text)
        var best = 0
        for mask in 0..<(1 << s.count) {
            let picked = s.indices.filter { mask & (1 << $0) != 0 }.map { s[$0] }
            if picked.count > best && picked == picked.reversed() {
                best = picked.count
            }
        }
        return best
    }

    /// Plain recursion on the insertions themselves: give an unmatched end a partner on the other side
    private func bruteInsertions(_ s: [Character], _ i: Int, _ j: Int) -> Int {
        if i >= j { return 0 }
        if s[i] == s[j] { return bruteInsertions(s, i + 1, j - 1) }
        return 1 + min(bruteInsertions(s, i + 1, j), bruteInsertions(s, i, j - 1))
    }

    /// A different method for long strings: the LCS of the text and its reverse, with two rows
    private func referenceLongest(_ text: String) -> Int {
        let a = Array(text.utf8), b = Array(a.reversed())
        var previous = [Int](repeating: 0, count: b.count + 1)
        var current = previous
        for x in a {
            for j in 1..<(b.count + 1) {
                current[j] = x == b[j - 1] ? previous[j - 1] + 1 : max(previous[j], current[j - 1])
            }
            swap(&previous, &current)
        }
        return previous[b.count]
    }

    private func randomText(_ alphabet: [Character], _ length: Int, _ random: inout PalindromeInsertRandom) -> String {
        String((0..<length).map { _ in alphabet[Int.random(in: 0..<alphabet.count, using: &random)] })
    }

    @Test("Examples and small cases", arguments: [
        ("race", 1, 3),
        ("abca", 3, 1),
        ("banana", 5, 1),
        ("racecar", 7, 0),
        ("character", 5, 4),
        ("swift", 1, 4),
        ("", 0, 0),
        ("a", 1, 0),
        ("ab", 1, 1),
        ("aa", 2, 0),
        ("noon", 4, 0),
    ])
    func examples(text: String, longest: Int, insertions: Int) {
        #expect(PalindromeByInsertions.longestPalindromicSubsequence(text) == longest)
        #expect(PalindromeByInsertions.fewestInsertions(text) == insertions)
    }

    @Test("Matches the brute force on 300 random short strings")
    func randomSmall() {
        var random = PalindromeInsertRandom(seed: 544)
        for _ in 0..<300 {
            let text = randomText(Array("abc"), Int.random(in: 0...10, using: &random), &random)
            #expect(PalindromeByInsertions.longestPalindromicSubsequence(text) == bruteLongest(text), "\"\(text)\"")
            #expect(PalindromeByInsertions.fewestInsertions(text) == bruteInsertions(Array(text), 0, text.count - 1), "\"\(text)\"")
        }
    }

    @Test("A random 2,000-character string")
    func longRandom() {
        var random = PalindromeInsertRandom(seed: 2_001)
        let text = randomText(Array("abcd"), 2_000, &random)
        let longest = referenceLongest(text)
        #expect(PalindromeByInsertions.longestPalindromicSubsequence(text) == longest)
        #expect(PalindromeByInsertions.fewestInsertions(text) == 2_000 - longest)
    }

    @Test("Long strings with known answers")
    func longPlanted() {
        var random = PalindromeInsertRandom(seed: 9)
        let half = randomText(Array("xyz"), 1_000, &random)
        let palindrome = half + String(half.reversed())
        #expect(PalindromeByInsertions.fewestInsertions(palindrome) == 0)
        #expect(PalindromeByInsertions.longestPalindromicSubsequence(palindrome) == 2_000)

        // "abab…ab": dropping the last b leaves "abab…a", which is a palindrome
        let alternating = String(repeating: "ab", count: 1_000)
        #expect(PalindromeByInsertions.longestPalindromicSubsequence(alternating) == 1_999)
        #expect(PalindromeByInsertions.fewestInsertions(alternating) == 1)
    }
}
