// Reference solution: Huffman bit packing. Packing shifts each code's bits into a byte, most
// significant first, and appends the byte when 8 bits have arrived; the last byte is padded with zeros.
// Unpacking builds the code tree in arrays (a binary trie: bit 0 goes left, bit 1 right) and walks it
// one bit at a time, emitting a character at each leaf. A step to a missing child, or running out of
// bits, means the data is damaged. O(total bits) both ways, plus O(total code length) for the tree.

public enum HuffmanBitPacking {
    public static func pack(_ text: String, codes: [Character: String]) -> [UInt8] {
        let table = codes.mapValues { code in code.map { $0 == "1" ? UInt8(1) : 0 } }
        var bytes: [UInt8] = []
        var current: UInt8 = 0
        var used = 0
        for character in text {
            for bit in table[character] ?? [] {
                current = current << 1 | bit
                used += 1
                if used == 8 {
                    bytes.append(current)
                    (current, used) = (0, 0)
                }
            }
        }
        if used > 0 {
            bytes.append(current << (8 - used))                 // pad the last byte with zeros
        }
        return bytes
    }

    public static func unpack(_ bytes: [UInt8], count: Int, codes: [Character: String]) -> String? {
        guard count > 0 else { return "" }
        // A lone symbol with the empty code: the count says everything, and there are no bits to read
        if codes.count == 1, let only = codes.first, only.value.isEmpty {
            return String(repeating: String(only.key), count: count)
        }

        // The code tree: node 0 is the root; child[node][bit] is -1 when there's no such branch
        var child: [[Int]] = [[-1, -1]]
        var symbol: [Character?] = [nil]
        for (character, code) in codes {
            var node = 0
            for bit in code {
                let side = bit == "1" ? 1 : 0
                if child[node][side] == -1 {
                    child[node][side] = child.count
                    child.append([-1, -1])
                    symbol.append(nil)
                }
                node = child[node][side]
            }
            symbol[node] = character
        }

        var output = ""
        var produced = 0
        var node = 0
        var bitIndex = 0
        let totalBits = bytes.count * 8
        while produced < count {
            guard bitIndex < totalBits else { return nil }       // the bits ran out
            let bit = Int(bytes[bitIndex / 8] >> (7 - bitIndex % 8) & 1)
            bitIndex += 1
            node = child[node][bit]
            guard node != -1 else { return nil }                 // no code starts like this
            if let character = symbol[node] {
                output.append(character)
                produced += 1
                node = 0
            }
        }
        return output
    }
}
