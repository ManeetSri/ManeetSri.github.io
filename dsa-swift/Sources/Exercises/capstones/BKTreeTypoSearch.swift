// Problem: BK-tree typo search (M74 · A spell checker with edit distance and a BK-tree)

public enum BKTreeTypoSearch {
    public struct SearchResult: Equatable {
        public let words: [String]
        public let distancesComputed: Int

        public init(words: [String], distancesComputed: Int) {
            self.words = words
            self.distancesComputed = distancesComputed
        }
    }

    public struct Tree {
        public init() {}

        /// How many different words the tree holds.
        public var count: Int { 0 }

        /// The first word inserted, or nil for an empty tree.
        public var root: String? { nil }

        /// Adds `word`, unless the tree already holds it.
        public mutating func insert(_ word: String) {
            // Write your solution here, then run:
            // swift test --filter BKTreeTypoSearchTests
        }

        /// The edges below `word`: edge distance to child word. Empty for a leaf or a missing word.
        public func children(of word: String) -> [Int: String] {
            return [:]
        }

        /// Every word within `tolerance` edits of `query`, closest first and then alphabetically,
        /// with the number of distances the search computed.
        public func search(_ query: String, tolerance: Int) -> SearchResult {
            return SearchResult(words: [], distancesComputed: -1)
        }
    }

    /// Levenshtein distance between two strings, counting Characters.
    public static func distance(_ a: String, _ b: String) -> Int {
        return -1
    }
}
