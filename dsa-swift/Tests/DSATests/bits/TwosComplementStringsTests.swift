import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TwosComplementStringsTests {
    @Test("Patterns", arguments: [
        (5, 8, "00000101"), (-5, 8, "11111011"), (-1, 8, "11111111"), (-128, 8, "10000000"), (127, 8, "01111111"),
        (0, 8, "00000000"), (300, 16, "0000000100101100"), (-1, 16, "1111111111111111"), (-32_768, 16, "1000000000000000"),
        (-1, 1, "1"), (0, 1, "0"), (-2, 2, "10"), (1, 2, "01"), (-3, 3, "101"), (-6, 5, "11010"),
    ])
    func patterns(value: Int, width: Int, expected: String) {
        #expect(TwosComplementStrings.pattern(of: value, width: width) == expected)
    }

    @Test("Patterns at 64 bits")
    func patterns64() {
        #expect(TwosComplementStrings.pattern(of: Int.min, width: 64) == "1" + String(repeating: "0", count: 63))
        #expect(TwosComplementStrings.pattern(of: Int.max, width: 64) == "0" + String(repeating: "1", count: 63))
        #expect(TwosComplementStrings.pattern(of: -1, width: 64) == String(repeating: "1", count: 64))
        #expect(TwosComplementStrings.pattern(of: 1, width: 64) == String(repeating: "0", count: 63) + "1")
    }

    @Test("Values", arguments: [
        ("11111011", -5), ("0101", 5), ("1000", -8), ("1", -1), ("0", 0), ("01", 1), ("10", -2),
        ("00000101", 5), ("10000001", -127), ("0111111111111111", 32_767), ("1000000000000000", -32_768),
    ])
    func values(pattern: String, expected: Int) {
        #expect(TwosComplementStrings.value(of: pattern) == expected)
    }

    @Test("Values at 64 bits")
    func values64() {
        #expect(TwosComplementStrings.value(of: String(repeating: "1", count: 64)) == -1)
        #expect(TwosComplementStrings.value(of: "1" + String(repeating: "0", count: 63)) == Int.min)
        #expect(TwosComplementStrings.value(of: "0" + String(repeating: "1", count: 63)) == Int.max)
    }

    @Test("Every Int8 and Int16 value: patterns match Swift's own bits, and read back")
    func roundTrips() {
        var wrong: [Int] = []
        for value in -128...127 {
            let byte = UInt8(bitPattern: Int8(value))
            let digits = String(byte, radix: 2)
            let expected = String(repeating: "0", count: 8 - digits.count) + digits
            let pattern = TwosComplementStrings.pattern(of: value, width: 8)
            if pattern != expected || TwosComplementStrings.value(of: pattern) != value {
                wrong.append(value)
            }
        }
        for value in stride(from: -32_768, through: 32_767, by: 7) {
            if TwosComplementStrings.value(of: TwosComplementStrings.pattern(of: value, width: 16)) != value {
                wrong.append(value)
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
    }

    @Test("Negations", arguments: [
        ("00000101", "11111011"), ("11111011", "00000101"), ("10000000", "10000000"), ("00000000", "00000000"),
        ("0110", "1010"), ("1", "1"), ("0", "0"), ("01", "11"), ("11111111", "00000001"),
    ])
    func negations(pattern: String, expected: String) {
        #expect(TwosComplementStrings.negated(pattern) == expected)
    }

    @Test("Negating gives the pattern of the negative value, for every Int8 except the minimum")
    func negationMatchesValues() {
        var wrong: [Int] = []
        for value in -127...127 {
            let pattern = TwosComplementStrings.pattern(of: value, width: 8)
            if TwosComplementStrings.negated(pattern) != TwosComplementStrings.pattern(of: -value, width: 8) {
                wrong.append(value)
            }
        }
        #expect(wrong.isEmpty, "wrong for \(Array(wrong.prefix(5)))")
        let minimum64 = "1" + String(repeating: "0", count: 63)
        #expect(TwosComplementStrings.negated(minimum64) == minimum64)
    }
}
