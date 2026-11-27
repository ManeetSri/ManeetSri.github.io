// Reference solution: Longest word built one letter at a time. Put every word in a trie, then walk it
// depth first, only stepping into children that end a word themselves: the nodes reached are exactly
// the words whose every prefix is a word. Children are visited alphabetically and a word only
// replaces the best when it's strictly longer, so ties go to the alphabetically smallest. O(total
// characters) time and space.

public enum LetterLadderWord {
    final class Node {
        var children = [Node?](repeating: nil, count: 26)
        var word: String?
    }

    public static func longest(in words: [String]) -> String {
        let root = Node()
        for word in words {
            var node = root
            for byte in word.utf8 {
                let slot = Int(byte - 97)
                if node.children[slot] == nil {
                    node.children[slot] = Node()
                }
                node = node.children[slot]!
            }
            node.word = word
        }

        var best = ""
        // An explicit stack, so long ladders can't overflow the call stack
        var pending: [Node] = [root]
        while let node = pending.popLast() {
            if let word = node.word {
                if word.utf8.count > best.utf8.count || (word.utf8.count == best.utf8.count && word < best) {
                    best = word
                }
            }
            for child in node.children.reversed() {
                if let child, child.word != nil {
                    pending.append(child)
                }
            }
        }
        return best
    }
}
