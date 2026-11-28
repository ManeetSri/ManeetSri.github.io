// Reference solution: Suggestions as you type. Put the catalogue in a trie whose nodes keep their 26
// children in alphabetical order, so a depth-first walk meets words alphabetically. Follow the typed
// text one letter at a time from the node reached so far (never from the root again), and at each
// step collect words below the current node until `limit` are found. Building costs O(total
// characters); each keystroke costs O(limit × the length of the words it visits).

public enum TypeaheadSuggestions {
    final class Node {
        var children = [Node?](repeating: nil, count: 26)
        var word: String?
    }

    public static func suggestions(for typed: String, in catalogue: [String], limit: Int) -> [[String]] {
        let root = Node()
        for entry in catalogue {
            var node = root
            for byte in entry.utf8 {
                let slot = Int(byte - 97)
                if node.children[slot] == nil {
                    node.children[slot] = Node()
                }
                node = node.children[slot]!
            }
            node.word = entry                    // repeats land on the same node
        }

        var result: [[String]] = []
        var current: Node? = root
        for byte in typed.utf8 {
            current = current?.children[Int(byte - 97)]
            var found: [String] = []
            if let node = current {
                collect(from: node, limit: limit, into: &found)
            }
            result.append(found)
        }
        return result
    }

    /// Appends words at or below `node` in alphabetical order, stopping once `found` holds `limit`.
    private static func collect(from node: Node, limit: Int, into found: inout [String]) {
        if found.count == limit { return }
        if let word = node.word {
            found.append(word)
        }
        for child in node.children {
            if found.count == limit { return }
            if let child {
                collect(from: child, limit: limit, into: &found)
            }
        }
    }
}
