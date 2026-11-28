// Reference solution: Words with nothing in common. One UInt64 set per word, so each pair is checked
// with a single AND. O(n × L + n²) time, O(n) space.

public enum DisjointLetterWords {
    public static func symbolSet(_ word: String) -> UInt64 {
        var set: UInt64 = 0
        for character in word {
            guard let ascii = character.asciiValue else { continue }
            let bit: UInt8
            switch ascii {
            case 97...122: bit = ascii - 97              // a…z
            case 65...90: bit = ascii - 65 + 26          // A…Z
            default: bit = ascii - 48 + 52               // 0…9
            }
            set |= 1 << bit
        }
        return set
    }

    public static func bestProduct(_ words: [String]) -> Int {
        let sets = words.map(symbolSet)
        let lengths = words.map { $0.utf8.count }        // every symbol is one ASCII byte
        var best = 0
        for i in 0..<words.count {
            for j in (i + 1)..<words.count where sets[i] & sets[j] == 0 {
                best = max(best, lengths[i] * lengths[j])
            }
        }
        return best
    }
}
