// Problem: Huffman bit packing (M74 · A Huffman compression CLI)

public enum HuffmanBitPacking {
    /// The codes of `text`'s characters, one after another, packed into bytes most significant bit
    /// first, with the last byte padded with zeros.
    public static func pack(_ text: String, codes: [Character: String]) -> [UInt8] {
        // Write your solution here, then run:
        // swift test --filter HuffmanBitPackingTests
        return [0xFF]
    }

    /// Decodes exactly `count` characters from `bytes`, or returns nil if the bits run out first or
    /// stop matching every code. Bits after the last character are ignored.
    public static func unpack(_ bytes: [UInt8], count: Int, codes: [Character: String]) -> String? {
        return nil
    }
}
