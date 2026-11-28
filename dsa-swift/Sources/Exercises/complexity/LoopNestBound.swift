// Problem: Bound the loop nests (M14 · Dropping constants, dominant terms, adding vs multiplying)

public enum LoopNestBound {
    /// One layer of a block: n passes, a halving loop, a fixed number of passes, or a call to `sorted()`.
    public enum Layer: Equatable {
        case linear
        case halving
        case fixed(Int)
        case sort
    }

    /// O(n^power × (log n)^logPower).
    public struct Bound: Equatable {
        public var power: Int
        public var logPower: Int

        public init(power: Int, logPower: Int) {
            self.power = power
            self.logPower = logPower
        }
    }

    /// The Big-O of blocks that run one after another, each a list of layers, outermost first.
    public static func bound(_ blocks: [[Layer]]) -> Bound {
        // Write your solution here, then run:
        // swift test --filter LoopNestBoundTests
        return Bound(power: -1, logPower: -1)
    }
}
