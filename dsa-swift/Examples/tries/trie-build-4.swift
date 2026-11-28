// Generated from src/dsa/content/lessons/tries/trie-build.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Trie {
    final class Node {
        var children: [Character: Node] = [:]
        var isWord = false
    }

    private let root = Node()

    func insert(_ word: String) {
        var node = root
        for character in word {
            if let next = node.children[character] {
                node = next
            } else {
                let next = Node()
                node.children[character] = next
                node = next
            }
        }
        node.isWord = true
    }

    func search(_ word: String) -> Bool {
        node(for: word)?.isWord ?? false
    }

    func startsWith(_ prefix: String) -> Bool {
        node(for: prefix) != nil
    }

    private func node(for text: String) -> Node? {
        var node = root
        for character in text {
            guard let next = node.children[character] else { return nil }
            node = next
        }
        return node
    }
}

// Short random words from three letters, so many share prefixes; the same every run
var seed = 40
func nextNumber(below limit: Int) -> Int {
    seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
    return (seed >> 16) % limit
}
let letters = Array("abc")
func randomWord() -> String {
    String((0...nextNumber(below: 5)).map { _ in letters[nextNumber(below: 3)] })
}

let trie = Trie()
var words = Set<String>()                        // the model: obviously correct, if slow for prefixes
var prefixes = Set<String>()
var checks = 0
var mismatches = 0
for _ in 0..<2_000 {
    let word = randomWord()
    if nextNumber(below: 2) == 0 {
        trie.insert(word)
        words.insert(word)
        for length in 1...word.count {
            prefixes.insert(String(word.prefix(length)))
        }
    } else {
        checks += 2
        if trie.search(word) != words.contains(word) { mismatches += 1 }
        if trie.startsWith(word) != prefixes.contains(word) { mismatches += 1 }
    }
}
print("distinct words:", words.count, "checks:", checks, "mismatches:", mismatches)
