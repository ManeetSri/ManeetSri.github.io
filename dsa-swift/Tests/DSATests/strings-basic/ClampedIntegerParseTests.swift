import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ClampedIntegerParseTests {
    @Test("Parses ordinary numbers", arguments: [
        ("42", 42),
        ("-42", -42),
        ("+42", 42),
        ("   7", 7),
        ("  -0012", -12),
        ("0", 0),
        ("-0", 0),
        ("00000000000000000000000000001", 1),
    ])
    func ordinary(text: String, expected: Int) {
        #expect(ClampedIntegerParse.parse(text) == expected)
    }

    @Test("Stops at the first non-digit", arguments: [
        ("314 is pi-ish", 314),
        ("12a34", 12),
        ("-5-5", -5),
        ("9.75", 9),
        ("1 000", 1),
    ])
    func stopsEarly(text: String, expected: Int) {
        #expect(ClampedIntegerParse.parse(text) == expected)
    }

    @Test("Returns 0 when there are no digits to read", arguments: [
        "",
        "   ",
        "-",
        "+",
        "+-12",
        "-+12",
        "words 987",
        " - 5",
        "\t42",
        "٣",
    ])
    func noDigits(text: String) {
        #expect(ClampedIntegerParse.parse(text) == 0)
    }

    @Test("Reaches the limits exactly")
    func limits() {
        #expect(ClampedIntegerParse.parse("9223372036854775807") == Int.max)
        #expect(ClampedIntegerParse.parse("-9223372036854775807") == -Int.max)
        #expect(ClampedIntegerParse.parse("-9223372036854775808") == Int.min)
    }

    @Test("Clamps instead of overflowing", arguments: [
        ("9223372036854775808", Int.max),
        ("-9223372036854775809", Int.min),
        ("99999999999999999999999", Int.max),
        ("  -123456789012345678901234567890xyz", Int.min),
        ("18446744073709551616", Int.max),
    ])
    func clamps(text: String, expected: Int) {
        #expect(ClampedIntegerParse.parse(text) == expected)
    }

    @Test("Handles long inputs quickly")
    func large() {
        #expect(ClampedIntegerParse.parse(String(repeating: " ", count: 100_000) + "-17") == -17)
        #expect(ClampedIntegerParse.parse(String(repeating: "0", count: 100_000) + "5") == 5)
        #expect(ClampedIntegerParse.parse(String(repeating: "9", count: 100_000)) == Int.max)
    }
}
