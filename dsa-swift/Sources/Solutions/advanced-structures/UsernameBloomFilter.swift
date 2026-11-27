// Reference solution: a Bloom filter of m bits packed into UInt64 words, with k positions per name from
// double hashing: h1 + i·h2 (mod m) for i in 0..<k, where h1 and h2 come from fixed hashes, so the bits
// are the same on every run and every device. Insert sets the k bits; a query answers "maybe" only if
// all k are set, so there are false positives but never false negatives. Each operation is O(k).

public enum UsernameBloomFilter {
    /// FNV-1a: a fixed 64-bit hash of a string's UTF-8 bytes.
    public static func fnv1a(_ text: String) -> UInt64 {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01B3
        }
        return hash
    }

    /// SplitMix64's finishing step: spreads every input bit across the whole output.
    public static func mix(_ x: UInt64) -> UInt64 {
        var z = x
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// The k that gives the lowest false positive rate: (bitCount / expectedCount) · ln 2, rounded to the
    /// nearest whole number, and at least 1.
    public static func bestHashCount(bitCount: Int, expectedCount: Int) -> Int {
        let ln2 = 0.693_147_180_559_945_3
        return max(1, Int((Double(bitCount) / Double(expectedCount) * ln2).rounded()))
    }

    public struct Filter {
        public let bitCount: Int
        public let hashCount: Int
        public private(set) var words: [UInt64]

        public init(bitCount: Int, hashCount: Int) {
            self.bitCount = bitCount
            self.hashCount = hashCount
            words = Array(repeating: 0, count: (bitCount + 63) / 64)
        }

        /// The bit positions for `name`, in order i = 0, 1, …, hashCount − 1.
        public static func positions(of name: String, bitCount: Int, hashCount: Int) -> [Int] {
            let h1 = mix(fnv1a(name))
            let h2 = mix(h1 ^ 0x9E37_79B9_7F4A_7C15) | 1
            let m = UInt64(bitCount)
            return (0..<hashCount).map { Int((h1 &+ UInt64($0) &* h2) % m) }
        }

        public mutating func insert(_ name: String) {
            for bit in Self.positions(of: name, bitCount: bitCount, hashCount: hashCount) {
                words[bit >> 6] |= 1 << UInt64(bit & 63)
            }
        }

        public func mightContain(_ name: String) -> Bool {
            Self.positions(of: name, bitCount: bitCount, hashCount: hashCount).allSatisfy {
                words[$0 >> 6] & (1 << UInt64($0 & 63)) != 0
            }
        }

        public var setBitCount: Int {
            words.reduce(0) { $0 + $1.nonzeroBitCount }
        }

        /// (fraction of bits set) raised to the power hashCount: the chance that a name never inserted
        /// finds all of its bits set.
        public var estimatedFalsePositiveRate: Double {
            let fraction = Double(setBitCount) / Double(bitCount)
            var rate = 1.0
            for _ in 0..<hashCount {
                rate *= fraction
            }
            return rate
        }

        /// Adds every name in `other`, a filter with the same size and hash count.
        public mutating func formUnion(_ other: Filter) {
            precondition(bitCount == other.bitCount && hashCount == other.hashCount, "Filters must match")
            for i in words.indices {
                words[i] |= other.words[i]
            }
        }
    }
}
