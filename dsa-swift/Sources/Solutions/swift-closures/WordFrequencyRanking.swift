// Reference solution: The most frequent words. Count with reduce(into:) in O(n), then sort the
// u distinct words in O(u log u). O(n + u log u) time, O(u) extra space.

public enum WordFrequencyRanking {
    public static func mostFrequent(_ words: [String], count k: Int) -> [String] {
        let counts = words.reduce(into: [String: Int]()) { tally, word in
            tally[word, default: 0] += 1
        }
        let ranked = counts.keys.sorted { first, second in
            let firstCount = counts[first]!
            let secondCount = counts[second]!
            if firstCount != secondCount {
                return firstCount > secondCount       // more frequent first
            }
            return first < second                     // then A to Z
        }
        return Array(ranked.prefix(k))
    }
}
