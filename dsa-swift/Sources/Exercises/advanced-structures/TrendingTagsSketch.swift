// Problem: Trending tags sketch (M64 · Bloom filters and count-min sketches)

public enum TrendingTagsSketch {
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

    /// The column `tag` uses in `row` of a sketch `width` counters wide. Given: don't change it.
    public static func column(of tag: String, row: Int, width: Int) -> Int {
        Int(mix(fnv1a(tag) &+ UInt64(row)) % UInt64(width))
    }

    /// A count-min sketch: `depth` rows of `width` counters.
    public struct Sketch {
        public let width: Int
        public let depth: Int

        public init(width: Int, depth: Int) {
            self.width = width
            self.depth = depth
        }

        /// The total of every count added so far.
        public var total: Int {
            // Write your solution here, then run:
            // swift test --filter TrendingTagsSketchTests
            return 0
        }

        /// Adds `count` to the tag's counter in every row.
        public mutating func add(_ tag: String, count: Int = 1) {
        }

        /// The smallest of the tag's counters: never less than its true count.
        public func estimate(_ tag: String) -> Int {
            return 0
        }

        /// The counter at `row`, `column`.
        public func counter(row: Int, column: Int) -> Int {
            return 0
        }

        /// Adds every counter of `other`, a sketch of the same width and depth, so this becomes the
        /// sketch of both streams.
        public mutating func merge(_ other: Sketch) {
        }
    }

    /// Feeds `stream` into a new sketch one tag at a time. Right after adding a tag, if its estimate is at
    /// least `threshold` and it hasn't been reported yet, it's reported. Returns the reported tags in the
    /// order they were reported.
    public static func heavyHitters(in stream: [String], width: Int, depth: Int, threshold: Int) -> [String] {
        return []
    }
}
