// Generated from src/dsa/content/lessons/tries/trie-autocomplete.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Character: Node] = [:]
    var isWord = false
}

let root = Node()
for word in ["cab", "car", "card", "care", "cart", "cat", "dog"] {
    var node = root
    for character in word {
        if node.children[character] == nil {
            node.children[character] = Node()
        }
        node = node.children[character]!
    }
    node.isWord = true
}

func firstWords(under node: Node, path: String, limit: Int) -> [String] {
    var found: [String] = []
    var pending = [(node, path)]                 // a stack, so the search is depth first
    while let (current, word) = pending.popLast(), found.count < limit {
        if current.isWord {
            found.append(word)
        }
        for character in current.children.keys.sorted().reversed() {
            pending.append((current.children[character]!, word + String(character)))
        }
    }
    return found
}

var stack = [root]                               // stack.last is the node for the text typed so far
var typed = ""
var lost = 0                                     // characters typed after falling off the trie
for key in ["c", "a", "r", "⌫", "t", "x", "⌫"] {
    if key == "⌫" {
        typed.removeLast()
        if lost > 0 { lost -= 1 } else { stack.removeLast() }
    } else {
        typed += key
        if lost == 0, let next = stack.last!.children[Character(key)] {
            stack.append(next)
        } else {
            lost += 1
        }
    }
    let shown = lost > 0 ? [] : firstWords(under: stack.last!, path: typed, limit: 3)
    print("typed \"\(typed)\":", shown)
}
