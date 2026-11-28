// Generated from src/dsa/content/lessons/tries/trie-concept.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TrieNode {
    var children: [Character: TrieNode] = [:]
    var isWord = false
}

let root = TrieNode()
var words: [String] = []
let letters = Array("abcdefghij")
for first in letters {
    for second in letters {
        for third in letters {
            words.append(String([first, second, third]))     // every 3-letter string from a to j
        }
    }
}
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

func trieSteps(_ word: String) -> Int {
    var node = root
    var steps = 0
    for character in word {
        guard let next = node.children[character] else { break }
        node = next
        steps += 1
    }
    return steps
}

print(words.count, "words")
print("trie steps to find jig:", trieSteps("jig"))
print("array comparisons to find jig:", words.firstIndex(of: "jig")! + 1)
print("trie steps to reject zzz:", trieSteps("zzz"))
