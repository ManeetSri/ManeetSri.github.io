// Problem: Hailstone numbers (M10 · Sequence and IteratorProtocol)

public enum HailstoneSequence {
    /// The hailstone sequence from `start`: halve even numbers, turn odd n into 3n + 1, and stop
    /// after reaching 1.
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

            // Write your solution here, then run:
            // swift test --filter HailstoneSequenceTests

            /// Returns the upcoming value and works out the one after it, or returns nil when finished.
            public mutating func next() -> Int? {
                return nil
            }
        }
    }

    /// The number of steps from `start` down to 1 (0 when `start` is 1).
    public static func stepsToOne(from start: Int) -> Int {
        return 0
    }

    /// The largest value in the sequence from `start`.
    public static func peak(from start: Int) -> Int {
        return 0
    }
}
