// Reference solution: Caesar shift.
// Reduce k to 0..<26 once (handling negatives), then turn each lowercase letter into its
// position, add the shift, wrap with % 26 and turn it back into a letter.
// O(n) time, O(n) space for the result.

public enum CaesarCipherShift {
    public static func shift(_ text: String, by k: Int) -> String {
        let step = ((k % 26) + 26) % 26
        var result = ""
        result.reserveCapacity(text.utf8.count)
        for character in text {
            guard let ascii = character.asciiValue, ascii >= 97, ascii <= 122 else {
                result.append(character)
                continue
            }
            let position = (Int(ascii) - 97 + step) % 26
            result.append(Character(UnicodeScalar(UInt8(97 + position))))
        }
        return result
    }
}
