// Problem: Implement a prefix tree (M40 · Build a Trie: insert, search, startsWith)

public enum PrefixTreeDesign {
    /// A prefix tree (trie) of lowercase words. Every operation should cost O(length of the word or
    /// prefix), however many words are stored.
    public final class PrefixTree {
        // Write your solution here, then run:
        // swift test --filter PrefixTreeDesignTests
        // Add a node class nested in here (so its name can't clash with anything) and a root node.

        /// Creates an empty prefix tree.
        public init() {
        }

        /// Adds `word`. Adding a word that's already there changes nothing.
        public func insert(_ word: String) {
        }

        /// True when `word` itself was inserted, not merely a longer word that starts with it.
        public func search(_ word: String) -> Bool {
            return false
        }

        /// True when at least one inserted word starts with `prefix` (a word starts with itself).
        public func startsWith(_ prefix: String) -> Bool {
            return false
        }
    }
}
