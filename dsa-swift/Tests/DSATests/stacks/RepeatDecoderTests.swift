import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RepeatDecoderTests {
    @Test("Decodes repeats", arguments: [
        ("3[ab]", "ababab"),
        ("2[a3[b]]c", "abbbabbbc"),
        ("x2[yz]w", "xyzyzw"),
        ("plain", "plain"),
        ("", ""),
        ("1[q]", "q"),
        ("2[]x", "x"),
        ("3[a]2[bc]", "aaabcbc"),
        ("2[2[2[o]]]", "oooooooo"),
    ])
    func decodes(encoded: String, expected: String) {
        #expect(RepeatDecoder.decode(encoded) == expected)
    }

    @Test("Counts can have several digits")
    func multiDigit() {
        #expect(RepeatDecoder.decode("12[z]") == String(repeating: "z", count: 12))
        #expect(RepeatDecoder.decode("10[a]1[b]") == "aaaaaaaaaab")
        #expect(RepeatDecoder.decode("100[ab]").count == 200)
    }

    @Test("Stays fast on a long output and on deep nesting")
    func large() {
        let long = RepeatDecoder.decode("50000[ab]")
        #expect(long.count == 100_000)
        #expect(long.hasPrefix("abab"))
        let deep = String(repeating: "1[", count: 2_000) + "deep" + String(repeating: "]", count: 2_000)
        #expect(RepeatDecoder.decode(deep) == "deep")
        let doubling = String(repeating: "2[", count: 16) + "a" + String(repeating: "]", count: 16)
        #expect(RepeatDecoder.decode(doubling).count == 65_536)
    }
}
