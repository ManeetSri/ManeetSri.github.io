// Reference solution: Hailstone numbers. Producing each value is O(1), so walking a sequence of
// length L is O(L) time and O(1) space; nothing is stored.

public enum HailstoneSequence {
    public struct Hailstone: Sequence {
        public let start: Int

        public init(start: Int) {
            self.start = start
        }

        public func makeIterator() -> Iterator {
            Iterator(upcoming: start)
        }

        public struct Iterator: IteratorProtocol {
            /// The value `next()` will return, or nil once the sequence has finished.
            var upcoming: Int?

            // Return the upcoming value, then work out the one after it. Reaching 1 ends the sequence.
            public mutating func next() -> Int? {
                guard let value = upcoming else { return nil }
                if value == 1 {
                    upcoming = nil
                } else if value.isMultiple(of: 2) {
                    upcoming = value / 2
                } else {
                    upcoming = 3 * value + 1
                }
                return value
            }
        }
    }

    // Every value after the first is one step
    public static func stepsToOne(from start: Int) -> Int {
        var steps = -1
        for _ in Hailstone(start: start) {
            steps += 1
        }
        return steps
    }

    public static func peak(from start: Int) -> Int {
        Hailstone(start: start).max() ?? start
    }
}
