import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SeenTwiceSubstringTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Longest length first, with every window of that length in a set. Fine for short texts.
    private static func bruteForce(_ text: String) -> Int {
        let s = Array(text.utf8)
        for length in stride(from: s.count - 1, to: 0, by: -1) {
            var seen = Set<ArraySlice<UInt8>>()
            for start in 0...(s.count - length) where !seen.insert(s[start..<(start + length)]).inserted {
                return length
            }
        }
        return 0
    }

    /// A different method for long texts: binary search on the length, with two polynomial hashes
    /// (different primes and bases) per window, so an accidental match is astronomically unlikely.
    private static func viaHashing(_ text: String) -> Int {
        let s = Array(text.utf8).map { Int($0) }
        let n = s.count
        let (m1, m2, b1, b2) = (2_147_483_647, 1_000_000_007, 911, 3_571)
        var p1 = [0], p2 = [0], w1 = [1], w2 = [1]
        for c in s {
            p1.append((p1.last! * b1 + c) % m1)
            p2.append((p2.last! * b2 + c) % m2)
            w1.append(w1.last! * b1 % m1)
            w2.append(w2.last! * b2 % m2)
        }
        func key(_ start: Int, _ length: Int) -> Int {
            let h1 = ((p1[start + length] - p1[start] * w1[length]) % m1 + m1) % m1
            let h2 = ((p2[start + length] - p2[start] * w2[length]) % m2 + m2) % m2
            return h1 * m2 + h2
        }
        func repeats(_ length: Int) -> Bool {
            var seen = Set<Int>()
            for start in 0...(n - length) where !seen.insert(key(start, length)).inserted {
                return true
            }
            return false
        }
        var low = 0, high = max(n - 1, 0)
        while low < high {
            let mid = (low + high + 1) / 2
            if repeats(mid) { low = mid } else { high = mid - 1 }
        }
        return low
    }

    @Test("Examples and edge cases", arguments: [
        ("banana", 3),
        ("abcd", 0),
        ("aaaa", 3),
        ("mississippi", 4),
        ("abab", 2),
        ("abcabcabc", 6),
        ("a", 0),
        ("", 0),
    ])
    func examples(text: String, expected: Int) {
        #expect(SeenTwiceSubstring.longestLength(in: text) == expected)
    }

    @Test("Matches brute force on 1,000 random short texts")
    func randomSmall() {
        var steps = Steps(seed: 21)
        for round in 0..<1_000 {
            let letters = Array(round % 2 == 0 ? "ab" : "abcd")
            let text = String((0..<steps.next(below: 25)).map { _ in letters[steps.next(below: letters.count)] })
            #expect(SeenTwiceSubstring.longestLength(in: text) == Self.bruteForce(text))
        }
    }

    @Test("100,000 a's, where comparing every pair of positions is far too slow")
    func structured() {
        #expect(SeenTwiceSubstring.longestLength(in: String(repeating: "a", count: 100_000)) == 99_999)
        #expect(SeenTwiceSubstring.longestLength(in: String(repeating: "ab", count: 15_000)) == 29_998)
        #expect(SeenTwiceSubstring.longestLength(in: String(repeating: "a", count: 29_999) + "b") == 29_998)
    }

    @Test("Random letters with a planted repeat, checked by hashing")
    func planted() {
        var steps = Steps(seed: 63)
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        var text = (0..<40_000).map { _ in letters[steps.next(below: 26)] }
        text.replaceSubrange(30_000..<33_000, with: text[5_000..<8_000])
        let planted = String(text)
        let expected = Self.viaHashing(planted)
        #expect(expected >= 3_000)
        #expect(SeenTwiceSubstring.longestLength(in: planted) == expected)

        let binary = String((0..<40_000).map { _ in letters[steps.next(below: 2)] })
        #expect(SeenTwiceSubstring.longestLength(in: binary) == Self.viaHashing(binary))
    }
}
