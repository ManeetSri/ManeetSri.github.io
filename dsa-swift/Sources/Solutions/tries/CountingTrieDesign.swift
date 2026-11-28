// Reference solution: A trie that counts. Every node keeps `endCount`, how many copies of its word
// are stored, and `passCount`, how many stored copies end at it or below it. Insert adds 1 to the
// pass count of every node on the path; remove first checks the word is there, then subtracts 1 on
// the way down, and the first node whose pass count reaches 0 is cut off with everything below it,
// because no stored word uses that branch any more. Every operation is O(length of the word).

public enum CountingTrieDesign {
    public final class CountingTrie {
        final class Node {
            var children: [Character: Node] = [:]
            var endCount = 0
            var passCount = 0
        }

        private let root = Node()
        public private(set) var nodeCount = 0

        public init() {}

        public func insert(_ word: String) {
            var node = root
            node.passCount += 1
            for character in word {
                if let next = node.children[character] {
                    node = next
                } else {
                    let next = Node()
                    node.children[character] = next
                    nodeCount += 1
                    node = next
                }
                node.passCount += 1
            }
            node.endCount += 1
        }

        public func count(of word: String) -> Int {
            node(for: word)?.endCount ?? 0
        }

        public func count(withPrefix prefix: String) -> Int {
            node(for: prefix)?.passCount ?? 0
        }

        public func remove(_ word: String) -> Bool {
            guard count(of: word) > 0 else { return false }
            let characters = Array(word)
            var node = root
            node.passCount -= 1
            for (depth, character) in characters.enumerated() {
                let child = node.children[character]!
                child.passCount -= 1
                if child.passCount == 0 {
                    // Nothing else passes through child: drop the rest of this word's path
                    node.children[character] = nil
                    nodeCount -= characters.count - depth
                    return true
                }
                node = child
            }
            node.endCount -= 1
            return true
        }

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
