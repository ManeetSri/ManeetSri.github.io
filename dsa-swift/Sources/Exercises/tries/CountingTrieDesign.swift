// Problem: A trie that counts (M40 · Deleting and counting prefixes)

public enum CountingTrieDesign {
    /// A trie that can hold several copies of a word, count words by prefix, and remove copies,
    /// pruning nodes that no stored word uses any more. Every operation should cost O(length of the
    /// word or prefix).
    public final class CountingTrie {
        // Write your solution here, then run:
        // swift test --filter CountingTrieDesignTests
        // Nest your node class in here, and give each node the counts it needs.

        /// Creates an empty trie.
        public init() {
        }

        /// Adds one copy of `word`. Inserting a word three times stores three copies.
        public func insert(_ word: String) {
        }

        /// How many copies of `word` are stored.
        public func count(of word: String) -> Int {
            return 0
        }

        /// How many stored copies start with `prefix`, counting every copy. The empty prefix counts
        /// every stored copy.
        public func count(withPrefix prefix: String) -> Int {
            return 0
        }

        /// Removes one copy of `word` and returns true, or returns false (changing nothing) if no copy
        /// is stored. Nodes that no stored word passes through any more must be removed.
        public func remove(_ word: String) -> Bool {
            return false
        }

        /// The number of nodes in the trie, not counting the root: one for every distinct non-empty
        /// prefix of the words currently stored.
        public var nodeCount: Int {
            return 0
        }
    }
}
