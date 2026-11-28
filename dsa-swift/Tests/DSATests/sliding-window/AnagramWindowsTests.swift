import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct AnagramWindowsTests {
    @Test("Finds every anagram start", arguments: [
        ("ab", "abab", [0, 1, 2]),
        ("tea", "eatate", [0, 3]),
        ("listen", "enlistsilent", [0, 5, 6]),
        ("aab", "baaab", [0, 2]),
        ("a", "banana", [1, 3, 5]),
        ("night", "night", [0]),
    ])
    func examples(pattern: String, text: String, expected: [Int]) {
        #expect(AnagramWindows.starts(of: pattern, in: text) == expected)
    }

    @Test("Returns an empty array when there's no anagram", arguments: [
        ("abc", "xyz"),
        ("zz", "z"),
        ("aa", "abab"),
        ("longer", "short"),
    ])
    func noAnagram(pattern: String, text: String) {
        #expect(AnagramWindows.starts(of: pattern, in: text).isEmpty)
    }

    @Test("Matches a brute force on many small strings")
    func matchesBruteForce() {
        let alphabet = Array("abc")
        var firstMismatch: String? = nil
        for seed in 0..<300 {
            let text = (0..<(seed % 14)).map { alphabet[($0 * 5 + seed * 3 + $0 / 3) % 3] }
            let pattern = (0..<(seed % 4 + 1)).map { alphabet[($0 + seed) % 3] }
            var expected: [Int] = []
            if pattern.count <= text.count {
                for start in 0...(text.count - pattern.count)
                where text[start..<start + pattern.count].sorted() == pattern.sorted() {
                    expected.append(start)
                }
            }
            if AnagramWindows.starts(of: String(pattern), in: String(text)) != expected {
                firstMismatch = firstMismatch ?? "\(String(pattern)) in \(String(text))"
            }
        }
        #expect(firstMismatch == nil, "the first pattern and text where the answer differs from the brute force")
    }

    @Test("Stays fast on long strings")
    func large() {
        let text = String(repeating: "abc", count: 33_334)          // 100,002 letters
        let every = AnagramWindows.starts(of: "cab", in: text)
        #expect(every.count == 100_000)
        #expect(every.first == 0)
        #expect(every.last == 99_999)

        // A 50,000-letter pattern: re-checking each window from scratch would take billions of steps
        let half = String(repeating: "ab", count: 25_000)
        let found = AnagramWindows.starts(of: half, in: String(repeating: "ba", count: 50_000))
        #expect(found.count == 50_001)
    }
}
