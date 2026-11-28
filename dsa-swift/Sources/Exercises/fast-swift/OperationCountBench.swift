// Problem: A benchmark harness that counts (M68 · Benchmarking properly)

import Foundation

public enum OperationCountBench {
    /// What `measure` reports.
    public struct Measurement: Equatable {
        /// The sample operation count at index samples / 2 after sorting.
        public let median: Int
        /// The smallest sample operation count.
        public let fewest: Int
        /// Every call's result (warm-up included), added with wrap-around.
        public let checksum: Int

        public init(median: Int, fewest: Int, checksum: Int) {
            self.median = median
            self.fewest = fewest
            self.checksum = checksum
        }
    }

    /// Whether a change made the work cheaper, dearer, or neither beyond the noise.
    public enum Verdict: Equatable {
        case faster, slower, noDifference
    }

    /// Calls `work` warmUp times, then `samples` times, and summarises the samples' operation counts.
    public static func measure(warmUp: Int, samples: Int, _ work: () -> (operations: Int, result: Int)) -> Measurement {
        // Write your solution here, then run:
        // swift test --filter OperationCountBenchTests
        return Measurement(median: -1, fewest: -1, checksum: 0)
    }

    /// Compares two versions' sample counts by their medians and spreads.
    public static func verdict(before: [Int], after: [Int]) -> Verdict {
        return .slower
    }

    /// The base-2 logarithm of the median ratio between consecutive costs at doubling sizes.
    public static func growthExponent(costs: [Int]) -> Double {
        return 0
    }
}
