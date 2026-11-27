// Problem: Weighted server picker (M67 · Reservoir sampling)

public enum WeightedServerPick {
    /// Picks server i with probability weights[i] / (sum of all weights). Servers with weight 0 are
    /// never picked. Draw every random number from the generator passed to `pick`.
    public final class Picker {
        // Write your solution here, then run:
        // swift test --filter WeightedServerPickTests
        // Add the private storage you need.

        /// Aim for O(n).
        public init(weights: [Int]) {
        }

        /// A random server index. Aim for O(log n).
        public func pick(using generator: inout some RandomNumberGenerator) -> Int {
            return 0
        }
    }
}
