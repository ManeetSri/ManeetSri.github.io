import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct EveryKthCharacterTests {
    @Test("Picks every kth character", arguments: [
        (2, "abcdefg", "aceg"),
        (3, "abcdefg", "adg"),
        (2, "abcdef", "ace"),
        (7, "abcdefg", "a"),
        (6, "abcdefg", "ag"),
        (4, "a b c d e", "ace"),
    ])
    func picks(k: Int, text: String, expected: String) {
        #expect(EveryKthCharacter.pick(every: k, from: text) == expected)
    }

    @Test("k = 1 keeps everything")
    func everyOne() {
        #expect(EveryKthCharacter.pick(every: 1, from: "swift") == "swift")
        #expect(EveryKthCharacter.pick(every: 1, from: "h\u{E9}llo\u{1F44B}") == "h\u{E9}llo\u{1F44B}")
    }

    @Test("A k longer than the text keeps only the first character", arguments: [5, 6, 1_000_000])
    func bigK(k: Int) {
        #expect(EveryKthCharacter.pick(every: k, from: "swift") == "s")
    }

    @Test("Empty text gives an empty result", arguments: [1, 2, 1_000_000])
    func empty(k: Int) {
        #expect(EveryKthCharacter.pick(every: k, from: "") == "")
    }

    @Test("Counts whole characters, not scalars or bytes")
    func unicode() {
        let wave = "\u{1F44B}\u{1F3FD}"
        let japan = "\u{1F1EF}\u{1F1F5}"
        #expect(EveryKthCharacter.pick(every: 2, from: wave + "a" + japan + "b") == wave + japan)
        #expect(EveryKthCharacter.pick(every: 2, from: "a" + wave + "b" + japan) == "ab")
        let decomposed = "e\u{301}xe\u{301}x"
        #expect(EveryKthCharacter.pick(every: 2, from: decomposed) == "\u{E9}\u{E9}")
        #expect(EveryKthCharacter.pick(every: 2, from: decomposed).unicodeScalars.count == 4)
    }

    @Test("Stays fast on 100,000 characters")
    func large() {
        let text = String(repeating: "abcdefghij", count: 10_000)
        #expect(EveryKthCharacter.pick(every: 1, from: text) == text)
        #expect(EveryKthCharacter.pick(every: 10, from: text) == String(repeating: "a", count: 10_000))
        #expect(EveryKthCharacter.pick(every: 7, from: text).count == 14_286)
    }
}
