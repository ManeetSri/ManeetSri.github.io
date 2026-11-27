import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private let romanCases: [(Int, String)] = [
    (1, "I"), (3, "III"), (4, "IV"), (9, "IX"), (14, "XIV"), (40, "XL"), (58, "LVIII"),
    (90, "XC"), (400, "CD"), (444, "CDXLIV"), (999, "CMXCIX"), (1994, "MCMXCIV"),
    (2024, "MMXXIV"), (3888, "MMMDCCCLXXXVIII"), (3999, "MMMCMXCIX"),
]

@Suite struct RomanNumeralCodecTests {
    @Test("Writes numbers as numerals", arguments: romanCases)
    func toRoman(number: Int, numeral: String) {
        #expect(RomanNumeralCodec.roman(from: number) == numeral)
    }

    @Test("Reads numerals as numbers", arguments: romanCases)
    func fromRoman(number: Int, numeral: String) {
        #expect(RomanNumeralCodec.value(of: numeral) == number)
    }

    @Test("Round-trips every number from 1 to 3999")
    func roundTrip() {
        var firstMismatch: Int? = nil
        for number in 1...3_999 where RomanNumeralCodec.value(of: RomanNumeralCodec.roman(from: number)) != number {
            firstMismatch = firstMismatch ?? number
        }
        #expect(firstMismatch == nil, "the first number that doesn't survive the round trip")
    }

    @Test("Never repeats a symbol four times in a row")
    func noFourInARow() {
        var firstBad: String? = nil
        for number in 1...3_999 {
            let numeral = RomanNumeralCodec.roman(from: number)
            if numeral.isEmpty || ["IIII", "XXXX", "CCCC", "MMMM", "VV", "LL", "DD"].contains(where: { numeral.contains($0) }) {
                firstBad = firstBad ?? "\(number): \(numeral)"
            }
        }
        #expect(firstBad == nil, "the first number written in a non-standard way")
    }
}
