// Generated from src/dsa/content/lessons/tries/trie-xor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Node?] = [nil, nil]           // children[0] for a 0 bit, children[1] for a 1 bit
}

let width = 5                                    // small numbers, so bits 4 down to 0 are enough
func binary(_ x: Int) -> String {
    let digits = String(x, radix: 2)
    return String(repeating: "0", count: width - digits.count) + digits
}

let root = Node()
for x in [12, 7, 19, 4, 30] {
    var node = root
    for bit in stride(from: width - 1, through: 0, by: -1) {
        let b = (x >> bit) & 1
        if node.children[b] == nil {
            node.children[b] = Node()
        }
        node = node.children[b]!
    }
}

// The best partner for 7: at each bit, take the opposite of 7's bit if it exists
let x = 7
var node = root
var partner = 0
print("x =", binary(x))
for bit in stride(from: width - 1, through: 0, by: -1) {
    let b = (x >> bit) & 1
    if let opposite = node.children[1 - b] {
        partner |= (1 - b) << bit
        node = opposite
        print("bit \(bit): x has \(b), took \(1 - b): the bits differ")
    } else {
        partner |= b << bit
        node = node.children[b]!
        print("bit \(bit): x has \(b), only \(b) exists: the bits match")
    }
}
print("partner =", binary(partner), "which is", partner)
print("x ^ partner =", binary(x ^ partner), "which is", x ^ partner)
