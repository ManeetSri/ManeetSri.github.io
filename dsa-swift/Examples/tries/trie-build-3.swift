// Generated from src/dsa/content/lessons/tries/trie-build.mdx. Edit the lesson, then run
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

func search(_ word: String) -> Bool {
    var node = root
    for character in word {
        guard let next = node.children[character] else { return false }
        node = next
    }
    return node.isWord
}

print(search(""))                 // nothing inserted yet
insert("")
print(search(""))                 // the root itself is now marked
insert("Car")
print(search("car"), search("Car"))
insert("Dog".lowercased())        // normalise words going in…
print(search("DOG".lowercased())) // …and queries too
