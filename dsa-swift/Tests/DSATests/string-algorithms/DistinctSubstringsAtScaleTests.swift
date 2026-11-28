import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DistinctSubstringsAtScaleTests {
    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// Every substring in a set: fine for short texts.
    private static func bruteForce(_ text: String) -> Int {
        let s = Array(text.utf8)
        var seen = Set<ArraySlice<UInt8>>()
        for start in s.indices {
            for end in (start + 1)...s.count { seen.insert(s[start..<end]) }
        }
        return seen.count
    }

    /// A different method for long texts: a suffix array by prefix doubling with a plain sort, then
    /// Kasai's LCP array, and n(n + 1)/2 minus the sum of the LCPs.
    private static func viaSuffixArray(_ text: String) -> Int {
        let s = Array(text.utf8)
        let n = s.count
        guard n > 1 else { return n }
        var sa = Array(0..<n)
        var rank = s.map { Int($0) }
        var newRank = [Int](repeating: 0, count: n)
        var k = 1
        while true {
            let current = rank
            func key(_ i: Int) -> (Int, Int) { (current[i], i + k < n ? current[i + k] : -1) }
            sa.sort { key($0) < key($1) }
            newRank[sa[0]] = 0
            for p in 1..<n { newRank[sa[p]] = newRank[sa[p - 1]] + (key(sa[p - 1]) < key(sa[p]) ? 1 : 0) }
            rank = newRank
            if rank[sa[n - 1]] == n - 1 { break }
            k *= 2
        }
        var shared = 0, h = 0
        for i in 0..<n {
            if rank[i] == 0 { h = 0; continue }
            let j = sa[rank[i] - 1]
            while i + h < n && j + h < n && s[i + h] == s[j + h] { h += 1 }
            shared += h
            if h > 0 { h -= 1 }
        }
        return n * (n + 1) / 2 - shared
    }

    @Test("Examples and edge cases", arguments: [
        ("aba", 5),
        ("abab", 7),
        ("aaaa", 4),
        ("abc", 6),
        ("banana", 15),
        ("mississippi", 53),
        ("a", 1),
        ("", 0),
    ])
    func examples(text: String, expected: Int) {
        #expect(DistinctSubstringsAtScale.count(in: text) == expected)
    }

    @Test("Matches brute force on 1,000 random short texts")
    func randomSmall() {
        var steps = Steps(seed: 40)
        for round in 0..<1_000 {
            let letters = Array(round % 2 == 0 ? "ab" : "abcz")
            let text = String((0..<steps.next(below: 30)).map { _ in letters[steps.next(below: letters.count)] })
            #expect(DistinctSubstringsAtScale.count(in: text) == Self.bruteForce(text))
        }
    }

    @Test("100,000 letters with known answers")
    func structured() {
        #expect(DistinctSubstringsAtScale.count(in: String(repeating: "a", count: 100_000)) == 100_000)
        #expect(DistinctSubstringsAtScale.count(in: String(repeating: "ab", count: 50_000)) == 199_999)
        // Every letter once, then a long run of one letter
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        let mixed = String(alphabet.reversed()) + String(repeating: "a", count: 1_000)
        #expect(DistinctSubstringsAtScale.count(in: mixed) == Self.viaSuffixArray(mixed))
    }

    @Test("Random letters, checked with a suffix array")
    func randomLong() {
        var steps = Steps(seed: 63)
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        let random = String((0..<40_000).map { _ in letters[steps.next(below: 26)] })
        #expect(DistinctSubstringsAtScale.count(in: random) == Self.viaSuffixArray(random))
        let binary = String((0..<40_000).map { _ in letters[steps.next(below: 2)] })
        #expect(DistinctSubstringsAtScale.count(in: binary) == Self.viaSuffixArray(binary))
    }
}
