import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RadixConverterTests {
    @Test("Converts the examples", arguments: [
        ("101101", 2, 10, "45"),
        ("2D", 16, 2, "101101"),
        ("2d", 16, 2, "101101"),
        ("zz", 36, 10, "1295"),
        ("ZZ", 36, 10, "1295"),
        ("0007", 8, 16, "7"),
        ("45", 10, 16, "2d"),
        ("777", 8, 10, "511"),
    ])
    func examples(digits: String, source: Int, target: Int, expected: String) {
        #expect(RadixConverter.convert(digits, from: source, to: target) == expected)
    }

    @Test("Writes zero as a single digit", arguments: [
        ("0", 10, 2),
        ("0000", 2, 36),
        ("0", 36, 10),
    ])
    func zero(digits: String, source: Int, target: Int) {
        #expect(RadixConverter.convert(digits, from: source, to: target) == "0")
    }

    @Test("Uses lower-case letters in the output")
    func lowerCaseOutput() {
        #expect(RadixConverter.convert("255", from: 10, to: 16) == "ff")
        #expect(RadixConverter.convert("35", from: 10, to: 36) == "z")
        #expect(RadixConverter.convert("1295", from: 10, to: 36) == "zz")
    }

    @Test("Same base in and out drops leading zeros")
    func sameBase() {
        #expect(RadixConverter.convert("00120", from: 10, to: 10) == "120")
        #expect(RadixConverter.convert("1010", from: 2, to: 2) == "1010")
    }

    @Test("Rejects text that isn't a number in the source base", arguments: [
        ("19", 8, 10),
        ("12", 2, 10),
        ("g", 16, 10),
        ("", 10, 2),
        ("-5", 10, 2),
        ("1 0", 10, 2),
        ("0x1f", 16, 10),
        ("+7", 10, 2),
        ("1é", 16, 10),
    ])
    func invalid(digits: String, source: Int, target: Int) {
        #expect(RadixConverter.convert(digits, from: source, to: target) == nil)
    }

    @Test("Handles values up to 10¹⁸")
    func large() {
        #expect(RadixConverter.convert("1000000000000000000", from: 10, to: 16) == "de0b6b3a7640000")
        #expect(RadixConverter.convert("de0b6b3a7640000", from: 16, to: 10) == "1000000000000000000")
        #expect(RadixConverter.convert("DE0B6B3A7640000", from: 16, to: 2) == String(1_000_000_000_000_000_000, radix: 2))
    }

    @Test("Agrees with the standard library for every base pair", arguments: [0, 1, 7, 35, 36, 255, 4096, 99_999, 123_456_789])
    func matchesStandardLibrary(value: Int) {
        var mismatches: [String] = []
        for source in 2...36 {
            let text = String(value, radix: source)
            for target in [2, 3, 8, 10, 16, 36] where RadixConverter.convert(text, from: source, to: target) != String(value, radix: target) {
                mismatches.append("\"\(text)\" from base \(source) to base \(target)")
            }
        }
        #expect(mismatches.isEmpty, "\(mismatches.count) wrong conversions, starting with \(mismatches.prefix(3))")
    }
}
