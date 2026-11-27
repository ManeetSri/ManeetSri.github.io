import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LongestUniqueRunTests {
    @Test("Finds the longest run with no repeats", arguments: [
        ("streets", 4),
        ("mississippi", 3),
        ("racecar", 4),
        ("swiftly", 7),
        ("aaaa", 1),
        ("a", 1),
        ("", 0),
        ("abba", 2),
        ("dvdf", 3),
        ("tmmzuxt", 5),
        ("abcbcad", 4),
        ("a b c a", 3),
    ])
    func examples(text: String, expected: Int) {
        #expect(LongestUniqueRun.length(of: text) == expected)
    }

    @Test("Counts whole characters, not bytes")
    func unicode() {
        #expect(LongestUniqueRun.length(of: "a😀b😀") == 3)
        #expect(LongestUniqueRun.length(of: "café") == 4)
    }

    @Test("Matches a brute force on many small strings")
    func matchesBruteForce() {
        let alphabet = Array("abcd")
        var firstMismatch: String? = nil
        for seed in 0..<400 {
            let chars = (0..<(seed % 12)).map { alphabet[($0 * $0 + seed * 7) % alphabet.count] }
            var best = 0
            for start in chars.indices {
                var seen = Set<Character>()
                for end in start..<chars.count {
                    if !seen.insert(chars[end]).inserted { break }
                    best = max(best, end - start + 1)
                }
            }
            if LongestUniqueRun.length(of: String(chars)) != best {
                firstMismatch = firstMismatch ?? String(chars)
            }
        }
        #expect(firstMismatch == nil, "the first string where the answer differs from the brute force")
    }

    @Test("Stays fast on long strings")
    func large() {
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        let cycling = String((0..<100_000).map { letters[$0 % 26] })
        #expect(LongestUniqueRun.length(of: cycling) == 26)

        // 20,000 different characters in a row, then the first one again
        let distinct = (0..<20_000).map { Character(Unicode.Scalar(0x4E00 + $0)!) }
        #expect(LongestUniqueRun.length(of: String(distinct + [distinct[0]])) == 20_000)
    }
}
