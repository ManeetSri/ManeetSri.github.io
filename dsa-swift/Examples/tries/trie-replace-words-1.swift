// Generated from src/dsa/content/lessons/tries/trie-replace-words.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Character: Node] = [:]
    var isRoot = false
}

func replaceWithRoots(_ sentence: String, roots: [String]) -> String {
    let trie = Node()
    for root in roots {
        var node = trie
        for character in root {
            if node.children[character] == nil {
                node.children[character] = Node()
            }
            node = node.children[character]!
        }
        node.isRoot = true
    }

    var result: [String] = []
    for word in sentence.split(separator: " ") {
        var node = trie
        var prefix = ""
        var replacement = String(word)
        for character in word {
            guard let next = node.children[character] else { break }    // no root goes this way
            node = next
            prefix.append(character)
            if node.isRoot {
                replacement = prefix                                     // the first root on the path
                break
            }
        }
        result.append(replacement)
    }
    return result.joined(separator: " ")
}

print(replaceWithRoots("the unhappy runners were unlucky", roots: ["un", "unhap", "run", "runner"]))
print(replaceWithRoots("swiftly swimming swans", roots: ["swim", "swift"]))
print(replaceWithRoots("a ab abc", roots: ["abc", "ab"]))
