// Reference solution: Decode digit messages. ways[i] = the number of decodings of the first i digits.
// The last letter used one digit (allowed if it's 1-9: add ways[i - 1]) or two digits (allowed if they
// make 10-26: add ways[i - 2]), with ways[0] = 1. Only the last two entries are read, so they roll.
// Work on the UTF-8 bytes so every access is O(1). O(n) time, O(n) space for the bytes.

public enum DigitMessageDecoder {
    public static func countDecodings(_ message: String) -> Int {
        let modulus = 1_000_000_007
        let digits = message.utf8.map { Int($0) - 48 }       // 48 is the byte for "0"
        var (twoBack, oneBack) = (0, 1)                      // ways[i - 2] and ways[i - 1], starting at i = 1
        for i in digits.indices {
            var current = 0
            if digits[i] != 0 {
                current = oneBack                             // one digit, 1-9
            }
            if i >= 1 {
                let pair = digits[i - 1] * 10 + digits[i]
                if pair >= 10 && pair <= 26 {
                    current = (current + twoBack) % modulus   // two digits, 10-26
                }
            }
            (twoBack, oneBack) = (oneBack, current)
        }
        return oneBack
    }
}
