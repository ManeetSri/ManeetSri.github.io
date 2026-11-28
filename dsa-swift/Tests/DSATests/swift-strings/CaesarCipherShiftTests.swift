import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CaesarCipherShiftTests {
    @Test("Shifts lowercase letters forward", arguments: [
        ("abc", 1, "bcd"),
        ("hello", 3, "khoor"),
        ("swift", 0, "swift"),
    ])
    func shifts(text: String, k: Int, expected: String) {
        #expect(CaesarCipherShift.shift(text, by: k) == expected)
    }

    @Test("Wraps from z back to a")
    func wraps() {
        #expect(CaesarCipherShift.shift("xyz", by: 3) == "abc")
        #expect(CaesarCipherShift.shift("z", by: 1) == "a")
    }

    @Test("Negative shifts move backwards")
    func negative() {
        #expect(CaesarCipherShift.shift("abc", by: -1) == "zab")
        #expect(CaesarCipherShift.shift("khoor", by: -3) == "hello")
        #expect(CaesarCipherShift.shift("a", by: -27) == "z")
    }

    @Test("Shifts of 26 or more wrap all the way round")
    func large() {
        #expect(CaesarCipherShift.shift("abc", by: 26) == "abc")
        #expect(CaesarCipherShift.shift("abc", by: 27) == "bcd")
        #expect(CaesarCipherShift.shift("abc", by: 1_000_000_000) == "mno")
        #expect(CaesarCipherShift.shift("abc", by: -1_000_000_000) == "opq")
    }

    @Test("Leaves everything that isn't a lowercase letter alone")
    func othersUnchanged() {
        #expect(CaesarCipherShift.shift("Hello, World! 42", by: 1) == "Hfmmp, Wpsme! 42")
        #expect(CaesarCipherShift.shift("ABC xyz", by: 2) == "ABC zab")
    }

    @Test("Returns an empty string for empty text")
    func empty() {
        #expect(CaesarCipherShift.shift("", by: 5) == "")
    }

    @Test("Shifting forward then back gives the original")
    func roundTrip() {
        let text = String(repeating: "the quick brown fox jumps over the lazy dog. ", count: 1_000)
        #expect(CaesarCipherShift.shift(CaesarCipherShift.shift(text, by: 11), by: -11) == text)
    }
}
