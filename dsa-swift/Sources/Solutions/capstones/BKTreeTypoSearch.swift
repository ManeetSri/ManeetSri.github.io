// Reference solution: BK-tree typo search. Nodes live in arrays; each node maps an edge distance to a
// child. Inserting walks down the edge labelled with the new word's distance from each node until that
// edge is free. Searching computes the query's distance d to a node and, by the triangle inequality,
// only follows edges e with |e - d| <= tolerance: no word below any other edge can be close enough.
// Insert costs one distance per level; a search computes one distance per node it visits.

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
        private var words: [[Character]] = []
        private var texts: [String] = []
        private var children: [[Int: Int]] = []                 // edge distance -> node index
        private var nodeOf: [String: Int] = [:]

        public init() {}

        public var count: Int { texts.count }

        public var root: String? { texts.first }

        public mutating func insert(_ word: String) {
            let letters = Array(word)
            guard !texts.isEmpty else {
                append(word, letters)
                return
            }
            var node = 0
            while true {
                let d = BKTreeTypoSearch.distance(letters, words[node])
                if d == 0 { return }                             // already in the tree
                if let next = children[node][d] {
                    node = next
                } else {
                    children[node][d] = texts.count
                    append(word, letters)
                    return
                }
            }
        }

        private mutating func append(_ word: String, _ letters: [Character]) {
            words.append(letters)
            texts.append(word)
            children.append([:])
            nodeOf[word] = texts.count - 1
        }

        public func children(of word: String) -> [Int: String] {
            guard let node = nodeOf[word] else { return [:] }
            return children[node].mapValues { texts[$0] }
        }

        public func search(_ query: String, tolerance: Int) -> SearchResult {
            guard !texts.isEmpty else { return SearchResult(words: [], distancesComputed: 0) }
            let letters = Array(query)
            var matches: [(distance: Int, word: String)] = []
            var computed = 0
            var stack = [0]                                      // explicit stack: depth can be large
            while let node = stack.popLast() {
                let d = BKTreeTypoSearch.distance(letters, words[node])
                computed += 1
                if d <= tolerance { matches.append((d, texts[node])) }
                for (edge, child) in children[node] where abs(edge - d) <= tolerance {
                    stack.append(child)
                }
            }
            matches.sort { ($0.distance, $0.word) < ($1.distance, $1.word) }
            return SearchResult(words: matches.map(\.word), distancesComputed: computed)
        }
    }

    /// Levenshtein distance between two strings, counting Characters.
    public static func distance(_ a: String, _ b: String) -> Int {
        distance(Array(a), Array(b))
    }

    /// Levenshtein distance with two rows: insertions, deletions and replacements each cost 1.
    static func distance(_ a: [Character], _ b: [Character]) -> Int {
        if a.isEmpty { return b.count }
        var previous = Array(0...b.count)
        var current = previous
        for i in 1...a.count {
            current[0] = i
            for j in stride(from: 1, through: b.count, by: 1) {
                let replace = previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1)
                current[j] = min(replace, previous[j] + 1, current[j - 1] + 1)
            }
            swap(&previous, &current)
        }
        return previous[b.count]
    }
}
