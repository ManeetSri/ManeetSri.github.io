// Problem: A trie in flat arrays (M68 · Index-based nodes vs class nodes)

public enum FlatArrayTrie {
    /// A trie of lowercase words with no node objects at all. Node n's 26 children are the Int32s at
    /// `children[n * 26 ..< n * 26 + 26]`, where 0 means "no child" (safe, because the root, node 0, is
    /// never anyone's child). `passCount[n]` counts the stored words that run through or end at node n.
    ///
    /// insert, contains and countWords(withPrefix:) are O(word length). Copying a Trie copies three arrays
    /// lazily, so copies are independent values for free.
    public struct Trie {
        private var children: [Int32] = Array(repeating: 0, count: 26)
        private var isWord: [Bool] = [false]
        private var passCount: [Int32] = [0]

        public init() {}

        public var nodeCount: Int {
            isWord.count
        }

        public var wordCount: Int {
            Int(passCount[0])
        }

        private static func slot(_ byte: UInt8) -> Int? {
            byte >= 97 && byte <= 122 ? Int(byte) - 97 : nil
        }

        /// The node reached by following `text` from the root, or nil
        private func find(_ text: String) -> Int? {
            var node = 0
            for byte in text.utf8 {
                guard let slot = Self.slot(byte) else { return nil }
                let next = Int(children[node * 26 + slot])
                if next == 0 { return nil }
                node = next
            }
            return node
        }

        public mutating func insert(_ word: String) {
            guard !word.isEmpty, !contains(word) else { return }
            var node = 0
            passCount[0] += 1
            for byte in word.utf8 {
                let slot = Int(byte) - 97
                var next = Int(children[node * 26 + slot])
                if next == 0 {
                    next = isWord.count
                    children[node * 26 + slot] = Int32(next)
                    children.append(contentsOf: repeatElement(0, count: 26))
                    isWord.append(false)
                    passCount.append(0)
                }
                node = next
                passCount[node] += 1
            }
            isWord[node] = true
        }

        public func contains(_ word: String) -> Bool {
            guard let node = find(word) else { return false }
            return isWord[node]
        }

        public func countWords(withPrefix prefix: String) -> Int {
            guard let node = find(prefix) else { return 0 }
            return Int(passCount[node])
        }

        public func child(of node: Int, letter: Character) -> Int? {
            guard let byte = letter.asciiValue, let slot = Self.slot(byte) else { return nil }
            let next = Int(children[node * 26 + slot])
            return next == 0 ? nil : next
        }
    }
}
