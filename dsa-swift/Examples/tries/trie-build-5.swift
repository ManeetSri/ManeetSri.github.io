// Generated from src/dsa/content/lessons/tries/trie-build.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ArrayNode {
    var children = [ArrayNode?](repeating: nil, count: 26)
    var isWord = false
}

// 2,000 made-up lowercase words of 3 to 8 letters, the same every run
var seed = 2_024
func nextNumber(below limit: Int) -> Int {
    seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
    return (seed >> 16) % limit
}
let alphabet = Array("abcdefghijklmnopqrstuvwxyz".utf8)
var words: [[UInt8]] = []
for _ in 0..<2_000 {
    words.append((0..<(3 + nextNumber(below: 6))).map { _ in alphabet[nextNumber(below: 26)] })
}

let root = ArrayNode()
var nodes = 1                                    // the root
for word in words {
    var node = root
    for byte in word {
        let slot = Int(byte - 97)
        if node.children[slot] == nil {
            node.children[slot] = ArrayNode()
            nodes += 1
        }
        node = node.children[slot]!
    }
    node.isWord = true
}

let slots = 26 * nodes
let used = nodes - 1                             // every node but the root fills one slot
print("nodes:", nodes)
print("child slots:", slots, "in use:", used)
print("share in use:", used * 100 / slots, "percent")
print("bytes per slot:", MemoryLayout<ArrayNode?>.size)
