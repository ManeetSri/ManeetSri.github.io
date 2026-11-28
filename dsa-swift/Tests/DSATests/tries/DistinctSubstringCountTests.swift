import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DistinctSubstringCountTests {
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
    static func bruteForce(_ text: String) -> Int {
        let letters = Array(text)
        var seen = Set<String>()
        for start in letters.indices {
            for end in start..<letters.count {
                seen.insert(String(letters[start...end]))
            }
        }
        return seen.count
    }

    /// A different method: sort the suffixes, then subtract the prefix each shares with the one
    /// before it, since those substrings were already counted.
    static func suffixSorting(_ text: String) -> Int {
        let letters = Array(text.utf8)
        let n = letters.count
        let order = (0..<n).sorted { letters[$0...].lexicographicallyPrecedes(letters[$1...]) }
        var total = n * (n + 1) / 2
        for k in order.indices.dropFirst() {
            var shared = 0
            let a = order[k - 1]
            let b = order[k]
            while a + shared < n && b + shared < n && letters[a + shared] == letters[b + shared] {
                shared += 1
            }
            total -= shared
        }
        return total
    }

    @Test("Examples from the statement", arguments: [
        ("aba", 5), ("aaaa", 4), ("abc", 6), ("", 0), ("a", 1), ("abab", 7),
    ])
    func examples(text: String, expected: Int) {
        #expect(DistinctSubstringCount.count(in: text) == expected)
    }

    @Test("Small random texts agree with a set of every substring")
    func smallRandom() {
        var steps = Steps(seed: 8)
        let letters = Array("abc")
        var mismatches = 0
        for _ in 0..<200 {
            let text = String((0..<steps.next(below: 25)).map { _ in letters[steps.next(below: 3)] })
            if DistinctSubstringCount.count(in: text) != Self.bruteForce(text) { mismatches += 1 }
        }
        #expect(mismatches == 0)
    }

    @Test("1,000 letters: repeated patterns with known answers")
    func patterns() {
        #expect(DistinctSubstringCount.count(in: String(repeating: "z", count: 1_000)) == 1_000)
        // Every length up to 999 has exactly two substrings, one starting with each letter
        #expect(DistinctSubstringCount.count(in: String(repeating: "ab", count: 500)) == 1_999)
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        #expect(DistinctSubstringCount.count(in: alphabet) == 26 * 27 / 2)
    }

    @Test("1,000 random letters agree with suffix sorting")
    func large() {
        var steps = Steps(seed: 1_000)
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        let text = String((0..<1_000).map { _ in letters[steps.next(below: 26)] })
        #expect(DistinctSubstringCount.count(in: text) == Self.suffixSorting(text))
        let binary = String((0..<1_000).map { _ in letters[steps.next(below: 2)] })
        #expect(DistinctSubstringCount.count(in: binary) == Self.suffixSorting(binary))
    }
}
