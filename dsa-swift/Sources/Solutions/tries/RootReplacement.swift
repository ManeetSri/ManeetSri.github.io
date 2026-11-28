// Reference solution: Shorten words to their roots. Build a trie of the roots. For each word, walk
// down the trie letter by letter: the first node that ends a root gives the shortest root, and
// falling off the trie means no root fits, so the word stays. O(total length of the roots + length of
// the sentence) time, O(total length of the roots) space.

public enum RootReplacement {
    final class Node {
        var children: [Character: Node] = [:]
        var isRoot = false
    }

    public static func replace(in sentence: String, roots: [String]) -> String {
        let trie = Node()
        for root in roots {
            var node = trie
            for character in root {
                if let next = node.children[character] {
                    node = next
                } else {
                    let next = Node()
                    node.children[character] = next
                    node = next
                }
            }
            node.isRoot = true
        }

        let words = sentence.split(separator: " ")
        let replaced = words.map { word -> Substring in
            var node = trie
            var length = 0
            for character in word {
                guard let next = node.children[character] else { return word }
                node = next
                length += 1
                if node.isRoot {
                    return word.prefix(length)   // the shortest root that fits
                }
            }
            return word
        }
        return replaced.joined(separator: " ")
    }
}
