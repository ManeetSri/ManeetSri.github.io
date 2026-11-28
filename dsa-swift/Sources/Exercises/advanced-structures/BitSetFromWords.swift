// Problem: Bitset from words (M64 · Sparse matrices and bitsets)

public enum BitSetFromWords {
    /// A set of the numbers 0..<capacity, one bit each: number x is bit x % 64 of words[x / 64], and
    /// words has (capacity + 63) / 64 elements. Bits past capacity in the last word are always 0.
    public struct Bits: Equatable {
        public let capacity: Int
        public private(set) var words: [UInt64]

        public init(capacity: Int) {
            self.capacity = capacity
            words = []
            // Write your solution here, then run:
            // swift test --filter BitSetFromWordsTests
        }

        /// Adds x, which must be in 0..<capacity.
        public mutating func insert(_ x: Int) {
        }

        /// Removes x, which must be in 0..<capacity. Removing a number that isn't there does nothing.
        public mutating func remove(_ x: Int) {
        }

        /// True if x is in the set. False for any number outside 0..<capacity.
        public func contains(_ x: Int) -> Bool {
            return false
        }

        /// The number of members.
        public var count: Int {
            return 0
        }

        /// The members in increasing order.
        public var elements: [Int] {
            return []
        }

        /// The smallest member ≥ x, or nil if there isn't one. x may be negative or ≥ capacity.
        public func next(atOrAfter x: Int) -> Int? {
            return nil
        }

        /// Adds every member of `other`, a set with the same capacity.
        public mutating func formUnion(_ other: Bits) {
        }

        /// Keeps only the members also in `other`, a set with the same capacity.
        public mutating func formIntersection(_ other: Bits) {
        }

        /// Removes every member of `other`, a set with the same capacity.
        public mutating func subtract(_ other: Bits) {
        }

        /// A set with the same capacity where every member x becomes x + s (s ≥ 0). Members that would
        /// reach capacity or beyond are dropped.
        public func shiftedUp(by s: Int) -> Bits {
            return self
        }
    }

    /// Every total from 0 to `limit` that some subset of `weights` adds up to (each weight used at most
    /// once; the empty subset makes 0), in increasing order. Weights are positive.
    public static func reachableSums(weights: [Int], limit: Int) -> [Int] {
        return []
    }
}
