// Problem: Distinct visitors in a few kilobytes (M64 · HyperLogLog)

import Foundation

public enum DistinctVisitorSketch {
    /// The fixed 64-bit hash every sketch uses: SplitMix64's mixing steps. Provided: use it unchanged.
    public static func mix(_ id: Int) -> UInt64 {
        var z = UInt64(bitPattern: Int64(id)) &+ 0x9E37_79B9_7F4A_7C15
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// A HyperLogLog sketch with 2^indexBits one-byte registers.
    public struct Sketch {
        // Write your solution here, then run:
        // swift test --filter DistinctVisitorSketchTests
        // Store the registers yourself, for example as `public private(set) var registers: [UInt8]`.

        /// b, the number of hash bits that choose a register (4...16).
        public let indexBits: Int

        /// Creates a sketch with 2^indexBits registers, all 0.
        public init(indexBits: Int) {
            self.indexBits = indexBits
        }

        /// The registers, in index order.
        public var registers: [UInt8] {
            return []
        }

        /// Adds one id: its register keeps the larger of its value and the id's rank. O(1).
        public mutating func add(_ id: Int) {
        }

        /// The estimated number of distinct ids added, with linear counting for small counts. O(m).
        public var estimate: Double {
            return 0
        }

        /// The sketch of both sets of ids: the larger of each pair of registers. O(m).
        public func merged(with other: Sketch) -> Sketch {
            return self
        }
    }

    /// The estimated number of ids added to both sketches: |A| + |B| − |A ∪ B|.
    public static func overlapEstimate(_ first: Sketch, _ second: Sketch) -> Double {
        return 0
    }
}
