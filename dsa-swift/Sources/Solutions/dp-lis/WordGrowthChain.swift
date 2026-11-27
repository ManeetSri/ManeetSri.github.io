// Reference solution: Longest word growth chain. A word can only grow from a word one letter shorter,
// so process words by length. For each word, delete each letter in turn and look the shorter word up
// in a dictionary of the longest chain ending at it; the word's own chain is one more than the best
// it finds. Duplicates simply overwrite the same entry.
// O(n log n + n · L²) time for n words of at most L letters, O(n · L) space.

public enum WordGrowthChain {
    public static func longestChain(_ words: [String]) -> Int {
        var chainEndingAt: [String: Int] = [:]
        var best = 0
        for word in words.sorted(by: { $0.count < $1.count }) {
            let letters = Array(word)
            var chain = 1
            for skip in letters.indices {
                var shorter = letters
                shorter.remove(at: skip)
                if let before = chainEndingAt[String(shorter)] {
                    chain = max(chain, before + 1)
                }
            }
            chainEndingAt[word] = chain
            best = max(best, chain)
        }
        return best
    }
}
