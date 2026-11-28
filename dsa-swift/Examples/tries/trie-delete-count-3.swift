// Generated from src/dsa/content/lessons/tries/trie-delete-count.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Character: Node] = [:]
    var isWord = false
    var passCount = 0
}

let root = Node()

func walk(_ text: String) -> Node? {
    var node = root
    for character in text {
        guard let next = node.children[character] else { return nil }
        node = next
    }
    return node
}

func insert(_ word: String) {
    if walk(word)?.isWord == true { return }
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

func remove(_ word: String) -> Bool {
    guard walk(word)?.isWord == true else { return false }
    var node = root
    node.passCount -= 1
    for character in word {
        let child = node.children[character]!
        child.passCount -= 1
        if child.passCount == 0 {
            node.children[character] = nil
            return true
        }
        node = child
    }
    node.isWord = false
    return true
}

func countNodes(_ node: Node) -> Int {
    node.children.values.reduce(0) { $0 + 1 + countNodes($1) }
}

for word in ["car", "cart", "care", "dog"] {
    insert(word)
}
print("start: nodes", countNodes(root))
for word in ["cart", "ca", "car", "dog", "care"] {
    let removed = remove(word)
    print("remove \(word): \(removed), nodes \(countNodes(root)), words under car: \(walk("car")?.passCount ?? 0)")
}
