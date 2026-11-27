// Problem: Rain gauge blocks (M62 · Sqrt decomposition)

public enum RainGaugeBlocks {
    /// A row of rain gauge readings with point corrections and two range questions. Ranges include both
    /// ends. Aim for about O(√n) per operation: blocks of about √n gauges, each with a stored summary.
    public final class Gauges {
        // Write your solution here, then run:
        // swift test --filter RainGaugeBlocksTests
        // Add the private storage you need.

        public init(readings: [Int]) {
        }

        /// Changes the reading of gauge `index` to `reading`.
        public func set(_ index: Int, to reading: Int) {
        }

        /// The sum of the readings of gauges `left...right`.
        public func total(_ left: Int, _ right: Int) -> Int {
            return 0
        }

        /// The largest reading among gauges `left...right`.
        public func heaviest(_ left: Int, _ right: Int) -> Int {
            return 0
        }
    }
}
