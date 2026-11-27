// Problem: Word counts in parallel (M70 · Why shared mutable state breaks)

public enum ShardedWordTally {
    /// How often each word appears across all `documents`. A word is a maximal run of letters
    /// (`Character.isLetter`), compared in lowercase. Count each document in its own child task of a
    /// task group, without sharing a dictionary between tasks, and combine the results.
    public static func counts(in documents: [String]) async -> [String: Int] {
        // Write your solution here, then run:
        // swift test --filter ShardedWordTallyTests
        return [:]
    }

    /// The `k` most frequent words across all `documents`, most frequent first, with ties broken
    /// alphabetically. Fewer than `k` if there aren't that many different words.
    public static func topWords(in documents: [String], count k: Int) async -> [String] {
        return []
    }
}
