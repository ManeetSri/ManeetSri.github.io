// Reference solution: Huffman-encoded length. Each merge in Huffman's algorithm adds one bit to every
// symbol inside the two trees it joins, so the total length is the sum of all merged weights. Count the
// symbols, put the counts in a min-heap, and repeatedly merge the two smallest. A text with one
// distinct symbol uses one bit per character. O(n + k log k) time for n characters and k distinct
// symbols, O(k) space.

import DSAKit

public enum HuffmanEncodedLength {
    public static func encodedBits(_ text: String) -> Int {
        var counts: [Character: Int] = [:]
        for symbol in text {
            counts[symbol, default: 0] += 1
        }
        if counts.count == 1 { return text.count }      // one symbol: a 1-bit code each
        var weights = Heap(counts.values, areInIncreasingOrder: <)
        var bits = 0
        while weights.count > 1 {
            let merged = weights.pop()! + weights.pop()!
            bits += merged
            weights.insert(merged)
        }
        return bits
    }
}
