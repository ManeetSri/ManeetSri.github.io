// Problem: Skip-ahead text search (M63 · Boyer–Moore's bad-character rule)

public enum HorspoolSkipSearch {
    /// Every position where `pattern` occurs in `text` (both ASCII), found with Boyer–Moore–Horspool's
    /// skip table exactly as the statement describes, and the number of alignments it checked. Empty
    /// positions and 0 alignments if the pattern is empty or longer than the text.
    public static func search(_ pattern: String, in text: String) -> (positions: [Int], alignments: Int) {
        // Write your solution here, then run:
        // swift test --filter HorspoolSkipSearchTests
        return ([], 0)
    }
}
