// Generated from src/dsa/content/lessons/tries/trie-delete-count.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class CountingTrie {
    final class Node {
        var children: [Character: Node] = [:]
        var isWord = false
        var passCount = 0                        // stored words that end here or below
    }

    private let root = Node()

    func search(_ word: String) -> Bool {
        node(for: word)?.isWord ?? false
    }

    func insert(_ word: String) {
        if search(word) { return }               // already stored: no count may change
        var node = root
        node.passCount += 1
        for character in word {
            if node.children[character] == nil {
                node.children[character] = Node()
            }
            node = node.children[character]!
            node.passCount += 1
        }
        node.isWord = true
    }

    func count(withPrefix prefix: String) -> Int {
        node(for: prefix)?.passCount ?? 0
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

let trie = CountingTrie()
for word in ["car", "card", "care", "careful", "cat", "dog", "car"] {
    trie.insert(word)
}
for prefix in ["", "c", "car", "care", "cards", "d"] {
    print("\"\(prefix)\":", trie.count(withPrefix: prefix))
}
