// Reference solution: Two's complement strings. Peel binary digits off the unsigned reading of the
// stored bits; read back with place values, building the leftmost weight −2^(width − 1) by doubling −1;
// negate by flipping the characters and adding 1 from the right. O(width).

public enum TwosComplementStrings {
    public static func pattern(of value: Int, width: Int) -> String {
        var bits = UInt64(bitPattern: Int64(value))         // the stored bits, no minus sign
        var digits: [Character] = []
        for _ in 0..<width {
            digits.append(bits % 2 == 1 ? "1" : "0")         // lowest bit first
            bits /= 2
        }
        return String(digits.reversed())
    }

    public static func value(of pattern: String) -> Int {
        let characters = Array(pattern)
        var rest = 0                                         // the ordinary bits after the first
        for character in characters.dropFirst() {
            rest = rest * 2 + (character == "1" ? 1 : 0)
        }
        guard characters[0] == "1" else {
            return rest
        }
        var weight = -1                                      // −2^(width − 1); −2⁶³ is Int.min
        for _ in 1..<characters.count {
            weight *= 2
        }
        return weight + rest
    }

    public static func negated(_ pattern: String) -> String {
        var characters = Array(pattern).map { $0 == "1" ? Character("0") : Character("1") }
        var index = characters.count - 1
        while index >= 0 && characters[index] == "1" {       // add 1: ones become zeros and carry
            characters[index] = "0"
            index -= 1
        }
        if index >= 0 {
            characters[index] = "1"                          // otherwise the carry falls off the end
        }
        return String(characters)
    }
}
