// Reference solution: Implement a prefix tree. Each node holds a dictionary from Character to child
// node and a flag saying whether a word ends there. All three operations walk down one edge per
// character, so each costs O(length of the word or prefix), however many words are stored. Memory is
// O(total characters inserted) in the worst case, less when words share prefixes.

public enum PrefixTreeDesign {
    public final class PrefixTree {
        final class Node {
            var children: [Character: Node] = [:]
            var isWord = false
        }

        private let root = Node()

        public init() {}

        public func insert(_ word: String) {
            var node = root
            for character in word {
                if let next = node.children[character] {
                    node = next
                } else {
                    let next = Node()
                    node.children[character] = next
                    node = next
                }
            }
            node.isWord = true
        }

        public func search(_ word: String) -> Bool {
            node(for: word)?.isWord ?? false
        }

        public func startsWith(_ prefix: String) -> Bool {
            node(for: prefix) != nil
        }

        /// The node reached by following `text` from the root, or nil if the path falls off.
        private func node(for text: String) -> Node? {
            var node = root
            for character in text {
                guard let next = node.children[character] else { return nil }
                node = next
            }
            return node
        }
    }
}
