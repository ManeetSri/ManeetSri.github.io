// Generated from src/dsa/content/lessons/tries/trie-autocomplete.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Character: Node] = [:]
    var frequency = 0                            // 0: no word ends here
}

let root = Node()

func insert(_ word: String, frequency: Int) {
    var node = root
    for character in word {
        if node.children[character] == nil {
            node.children[character] = Node()
        }
        node = node.children[character]!
    }
    node.frequency = frequency
}

func collect(_ node: Node, _ path: inout String, _ found: inout [(word: String, frequency: Int)]) {
    if node.frequency > 0 {
        found.append((path, node.frequency))
    }
    for character in node.children.keys.sorted() {
        path.append(character)
        collect(node.children[character]!, &path, &found)
        path.removeLast()
    }
}

func top(_ k: Int, withPrefix prefix: String) -> [String] {
    var node = root
    for character in prefix {
        guard let next = node.children[character] else { return [] }
        node = next
    }
    var found: [(word: String, frequency: Int)] = []
    var path = prefix
    collect(node, &path, &found)
    found.sort { $0.frequency != $1.frequency ? $0.frequency > $1.frequency : $0.word < $1.word }
    return found.prefix(k).map { $0.word }
}

let history = [("car", 120), ("card", 45), ("care", 300), ("careful", 45), ("cart", 80), ("cat", 500), ("catalog", 12)]
for (word, count) in history {
    insert(word, frequency: count)
}
print(top(3, withPrefix: "ca"))
print(top(5, withPrefix: "car"))
