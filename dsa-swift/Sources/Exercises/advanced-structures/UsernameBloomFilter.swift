// Problem: Username Bloom filter (M64 · Bloom filters and count-min sketches)

public enum UsernameBloomFilter {
    /// FNV-1a: a fixed 64-bit hash of a string's UTF-8 bytes. Given: don't change it.
    public static func fnv1a(_ text: String) -> UInt64 {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01B3
        }
        return hash
    }

    /// SplitMix64's finishing step: spreads every input bit across the whole output. Given: don't change it.
    public static func mix(_ x: UInt64) -> UInt64 {
        var z = x
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// The number of hashes that gives the lowest false positive rate: (bitCount / expectedCount) · ln 2,
    /// rounded to the nearest whole number, and at least 1. `expectedCount` is at least 1.
    public static func bestHashCount(bitCount: Int, expectedCount: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter UsernameBloomFilterTests
        return 0
    }

    /// A Bloom filter of `bitCount` bits, stored 64 to a word: bit b is bit b % 64 of words[b / 64].
    public struct Filter {
        public let bitCount: Int
        public let hashCount: Int
        public private(set) var words: [UInt64]

        public init(bitCount: Int, hashCount: Int) {
            self.bitCount = bitCount
            self.hashCount = hashCount
            words = []
        }

        /// The bit positions for `name`: with h1 = mix(fnv1a(name)) and
        /// h2 = mix(h1 ^ 0x9E37_79B9_7F4A_7C15) | 1, position i is (h1 &+ i &* h2) % bitCount, for
        /// i = 0, 1, …, hashCount − 1, all in UInt64 arithmetic.
        public static func positions(of name: String, bitCount: Int, hashCount: Int) -> [Int] {
            return []
        }

        /// Sets the bits at every position of `name`.
        public mutating func insert(_ name: String) {
        }

        /// False if `name` was definitely never inserted; true if it probably was.
        public func mightContain(_ name: String) -> Bool {
            return false
        }

        /// How many bits are set.
        public var setBitCount: Int {
            return 0
        }

        /// (setBitCount / bitCount) raised to the power hashCount.
        public var estimatedFalsePositiveRate: Double {
            return 0
        }

        /// Adds every name in `other`, a filter with the same bitCount and hashCount.
        public mutating func formUnion(_ other: Filter) {
        }
    }
}
