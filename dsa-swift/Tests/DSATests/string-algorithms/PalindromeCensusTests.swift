import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PalindromeCensusTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Check every substring: O(n³), so only for short texts.
    private static func bruteForce(_ text: String) -> Int {
        let s = Array(text.utf8)
        var count = 0
        for start in s.indices {
            for end in start..<s.count where s[start...end].elementsEqual(s[start...end].reversed()) {
                count += 1
            }
        }
        return count
    }

    /// Expand around every centre: quadratic on a string of one letter, but fast on random text,
    /// where palindromes are short.
    private static func expandAroundCentre(_ text: String) -> Int {
        let s = Array(text.utf8)
        var count = 0
        for centre in 0..<max(2 * s.count - 1, 0) {
            var low = centre / 2, high = low + centre % 2
            while low >= 0 && high < s.count && s[low] == s[high] {
                count += 1
                low -= 1
                high += 1
            }
        }
        return count
    }

    @Test("Examples and edge cases", arguments: [
        ("abc", 3),
        ("aaa", 6),
        ("abba", 6),
        ("racecar", 10),
        ("abaaba", 11),
        ("a", 1),
        ("", 0),
    ])
    func examples(text: String, expected: Int) {
        #expect(PalindromeCensus.count(in: text) == expected)
    }

    @Test("Matches brute force on 1,000 random short texts")
    func randomSmall() {
        var steps = Steps(seed: 4)
        for round in 0..<1_000 {
            let letters = Array(round % 2 == 0 ? "ab" : "abc")
            let text = String((0..<steps.next(below: 20)).map { _ in letters[steps.next(below: letters.count)] })
            #expect(PalindromeCensus.count(in: text) == Self.bruteForce(text))
        }
    }

    @Test("200,000 copies of one letter: n(n + 1)/2 palindromes")
    func oneLetter() {
        let n = 200_000
        #expect(PalindromeCensus.count(in: String(repeating: "a", count: n)) == n * (n + 1) / 2)
    }

    @Test("200,000 alternating letters: every odd-length substring is a palindrome")
    func alternating() {
        let n = 200_000
        let expected = (0..<n).reduce(0) { $0 + min($1, n - 1 - $1) + 1 }
        #expect(PalindromeCensus.count(in: String(repeating: "ab", count: n / 2)) == expected)
    }

    @Test("200,000 random letters, checked by expanding around every centre")
    func randomLong() {
        var steps = Steps(seed: 2_024)
        let letters = Array("ab")
        let text = String((0..<200_000).map { _ in letters[steps.next(below: 2)] })
        #expect(PalindromeCensus.count(in: text) == Self.expandAroundCentre(text))
    }
}
