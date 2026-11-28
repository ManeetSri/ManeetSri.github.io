// Generated from src/dsa/content/lessons/tries/trie-build.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Trie {
    final class Node {
        var children: [Character: Node] = [:]
        var isWord = false
    }

    private let root = Node()

    func insert(_ word: String) {
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

    func search(_ word: String) -> Bool {
        node(for: word)?.isWord ?? false
    }

    func startsWith(_ prefix: String) -> Bool {
        node(for: prefix) != nil
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

let trie = Trie()
for word in ["apple", "app", "apply", "ape"] {
    trie.insert(word)
}
for query in ["app", "appl", "apple", "apt", "b"] {
    print(query, "search:", trie.search(query), "startsWith:", trie.startsWith(query))
}
