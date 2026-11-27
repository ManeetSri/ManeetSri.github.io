// Generated from src/dsa/content/lessons/tries/trie-concept.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TrieNode {
    var children: [Character: TrieNode] = [:]
    var isWord = false
}

let root = TrieNode()

func insert(_ word: String) {
    var node = root
    for character in word {
        if node.children[character] == nil {
            node.children[character] = TrieNode()
        }
        node = node.children[character]!
    }
    node.isWord = true
}

func show(_ node: TrieNode, depth: Int) {
    for character in node.children.keys.sorted() {
        let child = node.children[character]!
        let mark = child.isWord ? "  (word)" : ""
        print(String(repeating: "  ", count: depth) + String(character) + mark)
        show(child, depth: depth + 1)
    }
}

for word in ["car", "cat", "cart", "dog", "do"] {
    insert(word)
}
show(root, depth: 0)
