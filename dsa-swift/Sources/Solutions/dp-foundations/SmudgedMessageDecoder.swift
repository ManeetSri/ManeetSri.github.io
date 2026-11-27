// Reference solution: Smudged digit messages. ways[i] counts (reading, decoding) pairs for the first
// i characters. The last letter used one character, which can be read as a digit 1-9 in `singles` ways,
// or two characters, which can be read as a number 10-26 in `pairs` ways. Every reading of those
// characters combines with every decoding of the prefix before them, so
// ways[i] = singles · ways[i - 1] + pairs · ways[i - 2], modulo 1,000,000,007. O(n) time.

public enum SmudgedMessageDecoder {
    public static func countDecodings(_ message: String) -> Int {
        let modulus = 1_000_000_007
        let characters = Array(message.utf8)
        var (twoBack, oneBack) = (0, 1)                      // ways[i - 2] and ways[i - 1], starting at i = 1
        for i in characters.indices {
            var current = singles(characters[i]) * oneBack % modulus
            if i >= 1 {
                current = (current + pairs(characters[i - 1], characters[i]) * twoBack) % modulus
            }
            (twoBack, oneBack) = (oneBack, current)
        }
        return oneBack
    }

    private static let smudge = UInt8(ascii: "?")
    private static let zero = UInt8(ascii: "0")

    /// How many readings of one character are a one-digit letter, 1 to 9
    private static func singles(_ character: UInt8) -> Int {
        if character == smudge {
            return 9                                         // any digit but 0
        }
        return character == zero ? 0 : 1
    }

    /// How many readings of two characters make a two-digit letter, 10 to 26
    private static func pairs(_ first: UInt8, _ second: UInt8) -> Int {
        switch (first == smudge, second == smudge) {
        case (true, true):
            return 17                                        // 10...19 and 20...26
        case (true, false):
            let units = Int(second - zero)
            return units <= 6 ? 2 : 1                        // 1u always works, 2u only up to 26
        case (false, true):
            let tens = Int(first - zero)
            return tens == 1 ? 10 : tens == 2 ? 7 : 0        // 10...19, or 20...26, or nothing
        case (false, false):
            let number = Int(first - zero) * 10 + Int(second - zero)
            return (10...26).contains(number) ? 1 : 0
        }
    }
}
