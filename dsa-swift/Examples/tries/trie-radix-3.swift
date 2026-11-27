// Generated from src/dsa/content/lessons/tries/trie-radix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Character: Node] = [:]
}

func suffixTrieNodes(_ text: String) -> Int {
    let letters = Array(text)
    let root = Node()
    var nodes = 0
    for start in letters.indices {               // insert the suffix starting at each position
        var node = root
        for character in letters[start...] {
            if node.children[character] == nil {
                node.children[character] = Node()
                nodes += 1
            }
            node = node.children[character]!
        }
    }
    return nodes
}

// Made-up DNA, the same every run
var seed = 11
let bases = Array("acgt")
func dna(_ length: Int) -> String {
    var text = ""
    for _ in 0..<length {
        seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
        text.append(bases[(seed >> 16) % 4])
    }
    return text
}

for n in [100, 200, 400] {
    let nodes = suffixTrieNodes(dna(n))
    print("n = \(n): \(nodes) nodes, n(n + 1)/2 = \(n * (n + 1) / 2)")
}
print("all a's, n = 400:", suffixTrieNodes(String(repeating: "a", count: 400)), "nodes")
