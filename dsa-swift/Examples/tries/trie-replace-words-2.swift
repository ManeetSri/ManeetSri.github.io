// Generated from src/dsa/content/lessons/tries/trie-replace-words.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Character: Node] = [:]
    var word: String?                            // the word that ends here, if any
}

func longestLadderWord(_ words: [String]) -> String {
    let root = Node()
    for word in words {
        var node = root
        for character in word {
            if node.children[character] == nil {
                node.children[character] = Node()
            }
            node = node.children[character]!
        }
        node.word = word
    }

    var best = ""
    func explore(_ node: Node) {
        for character in node.children.keys.sorted() {
            let child = node.children[character]!
            guard let word = child.word else { continue }    // a missing rung: go no further
            if word.count > best.count {
                best = word                                  // strictly longer only, so ties keep the earlier word
            }
            explore(child)
        }
    }
    explore(root)
    return best
}

print(longestLadderWord(["w", "wo", "wor", "worl", "world", "a", "ap", "app", "appl", "apple", "apply"]))
print(longestLadderWord(["m", "mo", "moo", "moon", "moonlight", "s", "su", "sun"]))
print(longestLadderWord(["to", "top"]).isEmpty)
