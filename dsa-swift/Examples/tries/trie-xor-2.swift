// Generated from src/dsa/content/lessons/tries/trie-xor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Node?] = [nil, nil]
}

let highestBit = 30                              // numbers below 2^31 use bits 30 down to 0

func insert(_ x: Int, into root: Node) {
    var node = root
    for bit in stride(from: highestBit, through: 0, by: -1) {
        let b = (x >> bit) & 1
        if node.children[b] == nil {
            node.children[b] = Node()
        }
        node = node.children[b]!
    }
}

func bestXor(with x: Int, in root: Node) -> Int {
    var node = root
    var result = 0
    for bit in stride(from: highestBit, through: 0, by: -1) {
        let b = (x >> bit) & 1
        if let opposite = node.children[1 - b] {
            result |= 1 << bit                   // the bits differ: this bit of the XOR is 1
            node = opposite
        } else {
            node = node.children[b]!             // forced to match: this bit of the XOR is 0
        }
    }
    return result
}

func largestXor(_ numbers: [Int]) -> Int {
    let root = Node()
    var best = 0
    for x in numbers {
        insert(x, into: root)                    // insert first, so the walk always succeeds
        best = max(best, bestXor(with: x, in: root))
    }
    return best
}

print(largestXor([12, 7, 19, 4, 30]))
print(largestXor([1_000_000_007, 123_456_789, 987_654_321]))
print(largestXor([42]))
