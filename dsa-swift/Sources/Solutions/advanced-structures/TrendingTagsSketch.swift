// Reference solution: a count-min sketch. `depth` rows of `width` counters; each row hashes a tag to one
// column with its own hash. Adding a tag increments its counter in every row; the estimate is the
// smallest of those counters, which can only overcount (collisions add) and never undercounts. Adding
// and estimating are O(depth); memory is O(width · depth) however many distinct tags there are.

public enum TrendingTagsSketch {
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

    /// The column `tag` uses in `row`: each row mixes the row number into the hash.
    public static func column(of tag: String, row: Int, width: Int) -> Int {
        Int(mix(fnv1a(tag) &+ UInt64(row)) % UInt64(width))
    }

    public struct Sketch {
        public let width: Int
        public let depth: Int
        public private(set) var total = 0
        private var counters: [Int]                 // row-major: row r, column c is r * width + c

        public init(width: Int, depth: Int) {
            self.width = width
            self.depth = depth
            counters = Array(repeating: 0, count: width * depth)
        }

        public mutating func add(_ tag: String, count: Int = 1) {
            let h = fnv1a(tag)
            for row in 0..<depth {
                counters[row * width + Int(mix(h &+ UInt64(row)) % UInt64(width))] += count
            }
            total += count
        }

        public func estimate(_ tag: String) -> Int {
            let h = fnv1a(tag)
            var smallest = Int.max
            for row in 0..<depth {
                smallest = min(smallest, counters[row * width + Int(mix(h &+ UInt64(row)) % UInt64(width))])
            }
            return smallest
        }

        public func counter(row: Int, column: Int) -> Int {
            counters[row * width + column]
        }

        /// Adds `other`'s counts, so this becomes the sketch of both streams. Same width and depth only.
        public mutating func merge(_ other: Sketch) {
            precondition(width == other.width && depth == other.depth, "Sketches must have the same shape")
            for i in counters.indices {
                counters[i] += other.counters[i]
            }
            total += other.total
        }
    }

    public static func heavyHitters(in stream: [String], width: Int, depth: Int, threshold: Int) -> [String] {
        var sketch = Sketch(width: width, depth: depth)
        var reported: Set<String> = []
        var result: [String] = []
        for tag in stream {
            sketch.add(tag)
            if sketch.estimate(tag) >= threshold && reported.insert(tag).inserted {
                result.append(tag)
            }
        }
        return result
    }
}
