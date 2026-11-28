// Problem: A trie in flat arrays (M68 · Index-based nodes vs class nodes)

public enum FlatArrayTrie {
    /// A trie of lowercase words (a–z) stored in arrays, with no node objects: each node is an Int
    /// index. The root is node 0, and new nodes are numbered 1, 2, 3, … in the order they're created.
    /// Copies of a Trie must be independent values.
    public struct Trie {
        /// An empty trie: just the root.
        public init() {
            // Write your solution here, then run:
            // swift test --filter FlatArrayTrieTests
        }

        /// The number of nodes, including the root.
        public var nodeCount: Int {
            return 0
        }

        /// The number of different words stored.
        public var wordCount: Int {
            return 0
        }

        /// Stores `word` (one or more letters a–z). Storing a word twice keeps one copy.
        public mutating func insert(_ word: String) {
        }

        /// True if `word` was inserted.
        public func contains(_ word: String) -> Bool {
            return false
        }

        /// How many stored words start with `prefix`. The empty prefix matches every word.
        public func countWords(withPrefix prefix: String) -> Int {
            return 0
        }

        /// The child of `node` for `letter`, or nil if there's no such child (or `letter` isn't a–z).
        public func child(of node: Int, letter: Character) -> Int? {
            return nil
        }
    }
}
