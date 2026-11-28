// Generated from src/dsa/content/lessons/dp-strings/dps-word-break.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class TrieNode {
    var children: [Character: TrieNode] = [:]
    var isWord = false
}

/// Word break pushed forwards: from every reachable start, walk the trie and mark each word end
func canSplit(_ text: String, _ words: [String]) -> Bool {
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
    let characters = Array(text)
    var ok = Array(repeating: false, count: characters.count + 1)
    ok[0] = true
    for start in characters.indices where ok[start] {
        var node = root
        var end = start
        while end < characters.count, let next = node.children[characters[end]] {
            node = next
            end += 1
            if node.isWord {
                ok[end] = true                     // characters[start..<end] is a word
            }
        }
    }
    return ok[characters.count]
}

let words = ["ice", "cream", "icecream", "cone", "con"]
print(canSplit("icecreamcone", words), canSplit("icecreamcones", words), canSplit("", words))
