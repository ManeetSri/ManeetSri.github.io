// Generated from src/dsa/content/lessons/tries/trie-radix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TrieNode {
    var children: [Character: TrieNode] = [:]
    var isWord = false
}

let words = ["in", "into", "integer", "integral", "internal", "internet", "interval", "interview"]
let root = TrieNode()
for word in words {
    var node = root
    for character in word {
        if node.children[character] == nil {
            node.children[character] = TrieNode()
        }
        node = node.children[character]!
    }
    node.isWord = true
}

var nodes = 0
var chainNodes = 0                               // one child, and no word ends here
var pending = [root]
while let node = pending.popLast() {
    for child in node.children.values {
        nodes += 1
        if child.children.count == 1 && !child.isWord {
            chainNodes += 1
        }
        pending.append(child)
    }
}
print("letters:", words.reduce(0) { $0 + $1.count })
print("trie nodes:", nodes)
print("nodes with one child and no word:", chainNodes)
