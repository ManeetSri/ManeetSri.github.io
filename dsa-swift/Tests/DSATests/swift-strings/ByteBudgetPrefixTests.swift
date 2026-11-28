import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ByteBudgetPrefixTests {
    @Test("Cuts ASCII text at the budget", arguments: [
        ("hello", 3, "hel"),
        ("hello", 5, "hello"),
        ("hello", 1, "h"),
        ("a b c", 4, "a b "),
    ])
    func ascii(text: String, maxBytes: Int, expected: String) {
        #expect(ByteBudgetPrefix.prefix(of: text, maxBytes: maxBytes) == expected)
    }

    @Test("Never splits a multi-byte character", arguments: [
        ("caf\u{E9}", 4, "caf"),
        ("caf\u{E9}", 5, "caf\u{E9}"),
        ("\u{20AC}10", 2, ""),
        ("\u{20AC}10", 4, "\u{20AC}1"),
        ("ok\u{1F44D}\u{1F3FD}", 9, "ok"),
        ("ok\u{1F44D}\u{1F3FD}", 10, "ok\u{1F44D}\u{1F3FD}"),
    ])
    func multiByte(text: String, maxBytes: Int, expected: String) {
        #expect(ByteBudgetPrefix.prefix(of: text, maxBytes: maxBytes) == expected)
    }

    @Test("Keeps a letter and its combining accent together")
    func combining() {
        let text = "cafe\u{301}!"
        #expect(ByteBudgetPrefix.prefix(of: text, maxBytes: 4).unicodeScalars.count == 3)
        #expect(ByteBudgetPrefix.prefix(of: text, maxBytes: 5).unicodeScalars.count == 3)
        #expect(ByteBudgetPrefix.prefix(of: text, maxBytes: 6).unicodeScalars.count == 5)
        #expect(ByteBudgetPrefix.prefix(of: text, maxBytes: 6) == "caf\u{E9}")
        #expect(ByteBudgetPrefix.prefix(of: text, maxBytes: 7) == text)
    }

    @Test("Treats a whole emoji sequence as one character")
    func emojiSequences() {
        let family = "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}"
        #expect(ByteBudgetPrefix.prefix(of: family + "!", maxBytes: 24) == "")
        #expect(ByteBudgetPrefix.prefix(of: family + "!", maxBytes: 25) == family)
        let flags = "\u{1F1EF}\u{1F1F5}\u{1F1EC}\u{1F1E7}"
        #expect(ByteBudgetPrefix.prefix(of: flags, maxBytes: 15) == "\u{1F1EF}\u{1F1F5}")
        #expect(ByteBudgetPrefix.prefix(of: flags, maxBytes: 7) == "")
    }

    @Test("Stops at the first character that doesn't fit, even if later ones would")
    func stopsAtFirstMisfit() {
        #expect(ByteBudgetPrefix.prefix(of: "a\u{1F600}bcd", maxBytes: 4) == "a")
    }

    @Test("A budget of 0 or an empty text gives an empty result")
    func empty() {
        #expect(ByteBudgetPrefix.prefix(of: "abc", maxBytes: 0) == "")
        #expect(ByteBudgetPrefix.prefix(of: "", maxBytes: 0) == "")
        #expect(ByteBudgetPrefix.prefix(of: "", maxBytes: 10) == "")
    }

    @Test("A big budget returns the whole text")
    func bigBudget() {
        let text = "na\u{EF}ve \u{1F44B}\u{1F3FE}"
        #expect(ByteBudgetPrefix.prefix(of: text, maxBytes: 1_000_000) == text)
        #expect(ByteBudgetPrefix.prefix(of: text, maxBytes: 15) == text)
        #expect(ByteBudgetPrefix.prefix(of: text, maxBytes: 14) == "na\u{EF}ve ")
    }

    @Test("Stays fast on 100,000 bytes")
    func large() {
        let ascii = String(repeating: "abcd", count: 25_000)
        #expect(ByteBudgetPrefix.prefix(of: ascii, maxBytes: 50_001).utf8.count == 50_001)
        let accented = String(repeating: "\u{E9}", count: 50_000)
        let cut = ByteBudgetPrefix.prefix(of: accented, maxBytes: 50_001)
        #expect(cut.utf8.count == 50_000)
        #expect(cut.count == 25_000)
    }
}
