import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct KeypadLetterWordsTests {
    private let keys: [Character: String] = ["2": "abc", "3": "def", "4": "ghi", "5": "jkl", "6": "mno", "7": "pqrs", "8": "tuv", "9": "wxyz"]

    /// Builds the words digit by digit with loops: every word so far, times every letter of the next key
    private func reference(_ digits: String) -> [String] {
        guard !digits.isEmpty else { return [] }
        var words = [""]
        for digit in digits {
            words = words.flatMap { word in keys[digit]!.map { word + String($0) } }
        }
        return words.sorted()
    }

    @Test("Examples and small cases", arguments: [
        ("47", ["gp", "gq", "gr", "gs", "hp", "hq", "hr", "hs", "ip", "iq", "ir", "is"]),
        ("9", ["w", "x", "y", "z"]),
        ("", []),
        ("22", ["aa", "ab", "ac", "ba", "bb", "bc", "ca", "cb", "cc"]),
    ] as [(String, [String])])
    func examples(digits: String, expected: [String]) {
        #expect(KeypadLetterWords.words(for: digits).sorted() == expected)
    }

    @Test("Every digit and some longer numbers", arguments: ["2", "3", "4", "5", "6", "7", "8", "9", "234", "7979", "56789", "2345"])
    func matchesLoops(digits: String) {
        #expect(KeypadLetterWords.words(for: digits).sorted() == reference(digits))
    }

    @Test("Eight digits on four-letter keys make 65,536 words")
    func longest() {
        let result = KeypadLetterWords.words(for: "79797979")
        #expect(result.count == 65_536)
        #expect(Set(result).count == 65_536)
        #expect(result.sorted() == reference("79797979"))
    }
}
