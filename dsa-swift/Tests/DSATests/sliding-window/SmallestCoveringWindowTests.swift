import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SmallestCoveringWindowTests {
    @Test("Finds the smallest covering window", arguments: [
        ("BANANABREAD", "ABD", "BREAD"),
        ("xaybzaxb", "aab", "aybza"),
        ("SWIFTLYSWIFT", "WIT", "WIFT"),
        ("ZXYAXZY", "XYZ", "ZXY"),
        ("helloworld", "lol", "llo"),
        ("thequickbrownfox", "ox", "ox"),
        ("aa", "aa", "aa"),
        ("q", "q", "q"),
        ("abcabc", "cba", "abc"),
    ])
    func examples(text: String, pattern: String, expected: String) {
        #expect(SmallestCoveringWindow.window(in: text, covering: pattern) == expected)
    }

    @Test("Returns an empty string when nothing covers the pattern", arguments: [
        ("a", "A"),
        ("abc", "d"),
        ("a", "aa"),
        ("abcab", "abcc"),
    ])
    func noWindow(text: String, pattern: String) {
        #expect(SmallestCoveringWindow.window(in: text, covering: pattern) == "")
    }

    @Test("Matches a brute force on many small strings")
    func matchesBruteForce() {
        let alphabet = Array("abcA")
        var firstMismatch: String? = nil
        for seed in 0..<250 {
            let text = (0..<(seed % 13)).map { alphabet[($0 * 7 + seed * 5 + $0 / 2) % 4] }
            let pattern = (0..<(seed % 3 + 1)).map { alphabet[($0 * 3 + seed) % 4] }
            var need: [Character: Int] = [:]
            for ch in pattern { need[ch, default: 0] += 1 }
            var expected = ""
            var found = false
            for length in 1...max(1, text.count) where !found && length <= text.count {
                for start in 0...(text.count - length) {
                    var have: [Character: Int] = [:]
                    for ch in text[start..<start + length] { have[ch, default: 0] += 1 }
                    if need.allSatisfy({ have[$0.key, default: 0] >= $0.value }) {
                        expected = String(text[start..<start + length])
                        found = true
                        break
                    }
                }
            }
            if SmallestCoveringWindow.window(in: String(text), covering: String(pattern)) != expected {
                firstMismatch = firstMismatch ?? "\(String(pattern)) in \(String(text))"
            }
        }
        #expect(firstMismatch == nil, "the first pattern and text where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 characters")
    func large() {
        let middle = String(repeating: "a", count: 50_000) + "bc" + String(repeating: "a", count: 49_998)
        #expect(SmallestCoveringWindow.window(in: middle, covering: "abc") == "abc")

        // The only covering window is the whole text
        let whole = "b" + String(repeating: "c", count: 99_997) + "aa"
        #expect(SmallestCoveringWindow.window(in: whole, covering: "aab") == whole)
    }
}
