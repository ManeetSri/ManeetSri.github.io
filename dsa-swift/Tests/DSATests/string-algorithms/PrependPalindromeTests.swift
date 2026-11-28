import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PrependPalindromeTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Find the longest palindromic prefix by checking every length, longest first. O(n²): fine when small.
    private static func naive(_ text: String) -> String {
        let s = Array(text.utf8)
        var length = s.count
        while length > 0 && !s[0..<length].elementsEqual(s[0..<length].reversed()) {
            length -= 1
        }
        return String(decoding: s[length...].reversed() + s, as: UTF8.self)
    }

    private static func randomText(_ length: Int, from letters: [Character], _ steps: inout Steps) -> String {
        String((0..<length).map { _ in letters[steps.next(below: letters.count)] })
    }

    @Test("Examples and edge cases", arguments: [
        ("aacecaaa", "aaacecaaa"),
        ("abcd", "dcbabcd"),
        ("", ""),
        ("a", "a"),
        ("aa", "aa"),
        ("ab", "bab"),
        ("abb", "bbabb"),
        ("aab", "baab"),
        ("racecar", "racecar"),
        ("abacabad", "dabacabad"),
    ])
    func examples(text: String, expected: String) {
        #expect(PrependPalindrome.shortest(from: text) == expected)
    }

    @Test("Matches the naive answer on 2,000 random short texts")
    func randomSmall() {
        var steps = Steps(seed: 7)
        for round in 0..<2_000 {
            let letters: [Character] = round % 3 == 0 ? ["a", "b", "c"] : ["a", "b"]
            let text = Self.randomText(steps.next(below: 25), from: letters, &steps)
            #expect(PrependPalindrome.shortest(from: text) == Self.naive(text))
        }
    }

    @Test("100,000 letters where checking every prefix is quadratic")
    func adversarial() {
        // Every prefix longer than the a's fails only when the comparison reaches the b
        let half = String(repeating: "a", count: 50_000)
        let text = half + "b" + String(repeating: "a", count: 49_999)
        #expect(PrependPalindrome.shortest(from: text) == String(repeating: "a", count: 49_999) + "b" + text)

        let allA = String(repeating: "a", count: 100_000)
        #expect(PrependPalindrome.shortest(from: allA) == allA)

        let alternating = String(repeating: "ab", count: 50_000)   // "abab…a" is a palindrome
        #expect(PrependPalindrome.shortest(from: alternating) == "b" + alternating)
    }

    @Test("A long planted palindrome followed by letters it can't extend into")
    func planted() {
        // The palindrome uses a and b, the tail uses c and d, so no longer prefix can be a palindrome
        var steps = Steps(seed: 63)
        let half = Self.randomText(30_000, from: ["a", "b"], &steps)
        let palindrome = half + String(half.reversed())
        let tail = Self.randomText(40_000, from: ["c", "d"], &steps)
        let text = palindrome + tail
        #expect(PrependPalindrome.shortest(from: text) == String(tail.reversed()) + text)
    }
}
