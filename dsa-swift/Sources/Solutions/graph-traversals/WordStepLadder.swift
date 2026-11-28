// Reference solution: Shortest word ladder. The words are the vertices of an implicit graph, joined
// when they differ in exactly one letter, and BFS finds the fewest steps. Rather than comparing every
// pair of words (O(n² · L)), each word is filed under its L wildcard patterns, so "cold" goes in the
// buckets "*old", "c*ld", "co*d" and "col*". Two words are neighbours exactly when they share a
// bucket. A bucket is emptied once it has been scanned, because every word in it has then been seen.
// O(n · L²) time to build the buckets (each pattern is a string of length L) and O(n · L) space.

public enum WordStepLadder {
    public static func fewestSteps(from start: String, to target: String, words: [String]) -> Int {
        if start == target { return 0 }
        let dictionary = Set(words)
        guard dictionary.contains(target) else { return -1 }

        var buckets: [String: [String]] = [:]
        for word in dictionary {
            for pattern in patterns(of: word) {
                buckets[pattern, default: []].append(word)
            }
        }

        var steps: [String: Int] = [start: 0]
        var queue = [start]
        var head = 0
        while head < queue.count {
            let word = queue[head]
            head += 1
            let nextSteps = steps[word]! + 1
            for pattern in patterns(of: word) {
                for next in buckets[pattern] ?? [] where steps[next] == nil {
                    if next == target { return nextSteps }
                    steps[next] = nextSteps
                    queue.append(next)
                }
                buckets[pattern] = nil                   // everything in it is seen now
            }
        }
        return -1
    }

    /// The word with each letter in turn replaced by "*"
    private static func patterns(of word: String) -> [String] {
        let letters = Array(word)
        return letters.indices.map { index in
            var pattern = letters
            pattern[index] = "*"
            return String(pattern)
        }
    }
}
