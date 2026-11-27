// Reference solution: a bitset over 0..<capacity, with number x at bit x & 63 of word x >> 6. Set
// operations combine whole words (|, &, & ~), so they cost O(capacity / 64). Members are listed by
// jumping between set bits with trailingZeroBitCount. Shifting up by s moves each word s >> 6 places
// and carries the top s & 63 bits of the word below; the bits past capacity in the last word are
// cleared after any operation that could set them. Subset sums: start from {0} and, for each weight w,
// OR in the set shifted up by w: O(n · limit / 64).

public enum BitSetFromWords {
    public struct Bits: Equatable {
        public let capacity: Int
        public private(set) var words: [UInt64]

        public init(capacity: Int) {
            self.capacity = max(0, capacity)
            words = Array(repeating: 0, count: (self.capacity + 63) / 64)
        }

        public mutating func insert(_ x: Int) {
            precondition(x >= 0 && x < capacity, "\(x) is outside 0..<\(capacity)")
            words[x >> 6] |= 1 << UInt64(x & 63)
        }

        public mutating func remove(_ x: Int) {
            precondition(x >= 0 && x < capacity, "\(x) is outside 0..<\(capacity)")
            words[x >> 6] &= ~(1 << UInt64(x & 63))
        }

        public func contains(_ x: Int) -> Bool {
            x >= 0 && x < capacity && words[x >> 6] & (1 << UInt64(x & 63)) != 0
        }

        public var count: Int {
            words.reduce(0) { $0 + $1.nonzeroBitCount }
        }

        public var elements: [Int] {
            var result: [Int] = []
            for (i, word) in words.enumerated() {
                var rest = word
                while rest != 0 {
                    result.append(i << 6 + rest.trailingZeroBitCount)
                    rest &= rest - 1
                }
            }
            return result
        }

        public func next(atOrAfter x: Int) -> Int? {
            let start = max(0, x)
            guard start < capacity else { return nil }
            var i = start >> 6
            var word = words[i] & (~0 << UInt64(start & 63))     // ignore bits below start
            while true {
                if word != 0 { return i << 6 + word.trailingZeroBitCount }
                i += 1
                guard i < words.count else { return nil }
                word = words[i]
            }
        }

        public mutating func formUnion(_ other: Bits) {
            precondition(capacity == other.capacity, "Capacities must match")
            for i in words.indices { words[i] |= other.words[i] }
        }

        public mutating func formIntersection(_ other: Bits) {
            precondition(capacity == other.capacity, "Capacities must match")
            for i in words.indices { words[i] &= other.words[i] }
        }

        public mutating func subtract(_ other: Bits) {
            precondition(capacity == other.capacity, "Capacities must match")
            for i in words.indices { words[i] &= ~other.words[i] }
        }

        public func shiftedUp(by s: Int) -> Bits {
            precondition(s >= 0, "Shift by a non-negative amount")
            var result = Bits(capacity: capacity)
            let wordShift = s >> 6
            let bitShift = UInt64(s & 63)
            guard wordShift < words.count else { return result }
            for i in stride(from: words.count - 1, through: wordShift, by: -1) {
                var word = words[i - wordShift] << bitShift
                if bitShift > 0 && i - wordShift > 0 {
                    word |= words[i - wordShift - 1] >> (64 - bitShift)
                }
                result.words[i] = word
            }
            let spare = words.count * 64 - capacity
            if spare > 0 {
                result.words[words.count - 1] &= ~UInt64(0) >> UInt64(spare)
            }
            return result
        }
    }

    public static func reachableSums(weights: [Int], limit: Int) -> [Int] {
        guard limit >= 0 else { return [] }
        var reachable = Bits(capacity: limit + 1)
        reachable.insert(0)
        for weight in weights where weight <= limit {
            reachable.formUnion(reachable.shiftedUp(by: weight))
        }
        return reachable.elements
    }
}
