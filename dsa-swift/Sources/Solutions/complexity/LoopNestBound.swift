// Reference solution: Bound the loop nests. Inside a block, costs multiply, so exponents add (a fixed
// loop adds nothing); across blocks, keep the dominant (power, logPower). O(total layers).

public enum LoopNestBound {
    public enum Layer: Equatable {
        case linear
        case halving
        case fixed(Int)
        case sort
    }

    public struct Bound: Equatable {
        public var power: Int
        public var logPower: Int

        public init(power: Int, logPower: Int) {
            self.power = power
            self.logPower = logPower
        }
    }

    public static func bound(_ blocks: [[Layer]]) -> Bound {
        var best = Bound(power: 0, logPower: 0)
        for block in blocks {
            var cost = Bound(power: 0, logPower: 0)
            for layer in block {
                switch layer {
                case .linear:
                    cost.power += 1
                case .halving:
                    cost.logPower += 1
                case .fixed:
                    break                       // a constant factor is dropped
                case .sort:
                    cost.power += 1             // n log n
                    cost.logPower += 1
                }
            }
            // Any power of n beats any power of log n, so compare the power first
            if (cost.power, cost.logPower) > (best.power, best.logPower) {
                best = cost
            }
        }
        return best
    }
}
