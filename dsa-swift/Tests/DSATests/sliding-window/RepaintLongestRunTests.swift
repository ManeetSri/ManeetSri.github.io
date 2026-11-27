import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RepaintLongestRunTests {
    @Test("Finds the longest run after at most k changes", arguments: [
        ("BAAAB", 1, 4),
        ("ABCDE", 1, 2),
        ("QQXQQYQQ", 1, 5),
        ("QQXQQYQQ", 2, 8),
        ("ZZZZ", 0, 4),
        ("ABBA", 0, 2),
        ("KAYAK", 2, 4),
        ("ABCABCAB", 2, 4),
        ("", 0, 0),
        ("M", 0, 1),
        ("XY", 2, 2),
    ])
    func examples(text: String, k: Int, expected: Int) {
        #expect(RepaintLongestRun.longest(text, changes: k) == expected)
    }

    @Test("Matches a brute force on many small strings")
    func matchesBruteForce() {
        let alphabet = Array("ABC")
        var firstMismatch: String? = nil
        for seed in 0..<300 {
            let chars = (0..<(seed % 12)).map { alphabet[($0 * $0 + seed * 5) % 3] }
            let k = seed % 4
            var best = 0
            for start in chars.indices {
                var counts: [Character: Int] = [:]
                for end in start..<chars.count {
                    counts[chars[end], default: 0] += 1
                    if (end - start + 1) - counts.values.max()! <= k {
                        best = max(best, end - start + 1)
                    }
                }
            }
            if RepaintLongestRun.longest(String(chars), changes: k) != best {
                firstMismatch = firstMismatch ?? "\(String(chars)) with k = \(k)"
            }
        }
        #expect(firstMismatch == nil, "the first case where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 letters")
    func large() {
        // In ABAB..., a window of length L needs L / 2 changes (rounded down), so k changes give 2k + 1
        let alternating = String(repeating: "AB", count: 50_000)
        #expect(RepaintLongestRun.longest(alternating, changes: 30_000) == 60_001)
        #expect(RepaintLongestRun.longest(alternating, changes: 0) == 1)
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let cycling = String((0..<100_000).map { letters[$0 % 26] })
        // A window of 27 letters holds one letter twice, so 25 changes are enough for it
        #expect(RepaintLongestRun.longest(cycling, changes: 25) == 27)
        #expect(RepaintLongestRun.longest(cycling, changes: 100_000) == 100_000)
    }
}
