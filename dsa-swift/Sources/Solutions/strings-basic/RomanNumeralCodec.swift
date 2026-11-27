// Reference solution: Roman numerals both ways. To read a numeral, add each symbol's value, but
// subtract it when a bigger symbol follows (IV, IX, XL, ...). To write one, take the largest value
// that still fits from a 13-entry table that includes the six subtractive pairs, again and again.
// Both directions are O(length of the numeral), which is at most 15.

public enum RomanNumeralCodec {
    private static let table: [(value: Int, symbol: String)] = [
        (1000, "M"), (900, "CM"), (500, "D"), (400, "CD"),
        (100, "C"), (90, "XC"), (50, "L"), (40, "XL"),
        (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I"),
    ]

    public static func roman(from number: Int) -> String {
        var remaining = number
        var result = ""
        for (value, symbol) in table {
            while remaining >= value {
                result += symbol
                remaining -= value
            }
        }
        return result
    }

    public static func value(of numeral: String) -> Int {
        let values = numeral.map(symbolValue)
        var total = 0
        for index in values.indices {
            if index + 1 < values.count && values[index] < values[index + 1] {
                total -= values[index]          // a smaller symbol before a bigger one
            } else {
                total += values[index]
            }
        }
        return total
    }

    private static func symbolValue(_ symbol: Character) -> Int {
        switch symbol {
        case "I": return 1
        case "V": return 5
        case "X": return 10
        case "L": return 50
        case "C": return 100
        case "D": return 500
        case "M": return 1000
        default: return 0
        }
    }
}
