// Generated from src/dsa/content/lessons/fast-swift/fs-index-based-nodes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct FlatTrie {
    private var children = [Int32](repeating: 0, count: 26)   // node n's children: n * 26 ..< n * 26 + 26
    private var isWord = [false]                                // one entry per node; the root is node 0

    var nodeCount: Int { isWord.count }

    mutating func insert(_ word: String) {
        var node = 0
        for byte in word.utf8 {
            let slot = node * 26 + Int(byte - 97)                // "a" is 97
            if children[slot] == 0 {                             // no child yet: create node number nodeCount
                children[slot] = Int32(isWord.count)
                children.append(contentsOf: repeatElement(0, count: 26))
                isWord.append(false)
            }
            node = Int(children[slot])
        }
        isWord[node] = true
    }

    func contains(_ word: String) -> Bool {
        var node = 0
        for byte in word.utf8 {
            let next = children[node * 26 + Int(byte - 97)]
            if next == 0 { return false }
            node = Int(next)
        }
        return isWord[node]
    }
}

var trie = FlatTrie()
for word in ["tea", "ten", "to", "inn"] {
    trie.insert(word)
}
print(trie.contains("ten"), trie.contains("te"), trie.contains("inn"))
print("nodes:", trie.nodeCount)
