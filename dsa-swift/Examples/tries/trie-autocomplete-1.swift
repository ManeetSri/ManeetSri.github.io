// Generated from src/dsa/content/lessons/tries/trie-autocomplete.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Character: Node] = [:]
    var isWord = false
}

let root = Node()

func insert(_ word: String) {
    var node = root
    for character in word {
        if node.children[character] == nil {
            node.children[character] = Node()
        }
        node = node.children[character]!
    }
    node.isWord = true
}

func collect(_ node: Node, _ path: inout String, _ found: inout [String], _ limit: Int) {
    if found.count == limit { return }
    if node.isWord {
        found.append(path)
    }
    for character in node.children.keys.sorted() {
        path.append(character)
        collect(node.children[character]!, &path, &found, limit)
        path.removeLast()
    }
}

func words(withPrefix prefix: String, limit: Int = Int.max) -> [String] {
    var node = root
    for character in prefix {
        guard let next = node.children[character] else { return [] }
        node = next
    }
    var found: [String] = []
    var path = prefix
    collect(node, &path, &found, limit)
    return found
}

for word in ["cart", "car", "careful", "cat", "card", "do", "care", "catalog", "dog"] {
    insert(word)
}
print(words(withPrefix: "car"))
print(words(withPrefix: "ca", limit: 3))
print(words(withPrefix: "d"))
print(words(withPrefix: "x"))
