// Reference solution: Word tally.
// The default: subscript treats a missing word as 0, so one line counts it.
// O(n) time on average, O(u) extra space for u distinct words.

public enum WordTally {
    public static func tally(_ words: [String]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for word in words {
            counts[word, default: 0] += 1
        }
        return counts
    }
}
