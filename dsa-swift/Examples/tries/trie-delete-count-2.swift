// Generated from src/dsa/content/lessons/tries/trie-delete-count.mdx. Edit the lesson, then run
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

func walk(_ text: String) -> Node? {
    var node = root
    for character in text {
        guard let next = node.children[character] else { return nil }
        node = next
    }
    return node
}

func countNodes(_ node: Node) -> Int {
    node.children.values.reduce(0) { $0 + 1 + countNodes($1) }
}

insert("car")
insert("cart")
walk("cart")?.isWord = false                     // "delete" cart by clearing its flag
print("search cart:", walk("cart")?.isWord ?? false)
print("startsWith cart:", walk("cart") != nil)
print("nodes below the root:", countNodes(root))
