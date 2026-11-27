// Problem: Words with nothing in common (M16 · Gray code and UInt64 bitsets)

public enum DisjointLetterWords {
    /// The symbols of `word` as a set: a…z are bits 0…25, A…Z bits 26…51, 0…9 bits 52…61.
    public static func symbolSet(_ word: String) -> UInt64 {
        // Write your solution here, then run:
        // swift test --filter DisjointLetterWordsTests
        return 0
    }

    /// The largest product of lengths of two words (at different positions) sharing no symbol, or 0.
    public static func bestProduct(_ words: [String]) -> Int {
        return -1
    }
}
