// Reference solution: Change of base. Read the text into an Int with Horner's rule
// (value = value * source + digit), then write it out with repeated division by the target base,
// collecting remainders and reversing. O(d) time and space for d digits.

public enum RadixConverter {
    private static let symbols = Array("0123456789abcdefghijklmnopqrstuvwxyz")

    public static func convert(_ digits: String, from source: Int, to target: Int) -> String? {
        guard !digits.isEmpty else { return nil }

        var value = 0
        for character in digits {
            guard let digit = digitValue(of: character), digit < source else { return nil }
            value = value * source + digit
        }

        var output: [Character] = []
        repeat {
            output.append(symbols[value % target])
            value /= target
        } while value > 0
        return String(output.reversed())
    }

    private static func digitValue(of character: Character) -> Int? {
        guard let code = character.asciiValue else { return nil }
        switch code {
        case 48...57: return Int(code) - 48        // "0" to "9"
        case 97...122: return Int(code) - 97 + 10  // "a" to "z"
        case 65...90: return Int(code) - 65 + 10   // "A" to "Z"
        default: return nil
        }
    }
}
