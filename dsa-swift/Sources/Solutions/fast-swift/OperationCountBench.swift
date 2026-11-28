// Reference solution: A benchmark harness that counts. Warm-up calls only feed the checksum; sample calls
// also record their operation counts, which are sorted once for the median and the fewest. Results are
// folded in with &+ so nothing can trap. The verdict compares medians against the larger interquartile
// spread, and the growth exponent is log2 of the median ratio between doubling sizes, so one disturbed
// measurement can't skew either. O(s log s) for s samples.

import Foundation

public enum OperationCountBench {
    public struct Measurement: Equatable {
        public let median: Int
        public let fewest: Int
        public let checksum: Int

        public init(median: Int, fewest: Int, checksum: Int) {
            self.median = median
            self.fewest = fewest
            self.checksum = checksum
        }
    }

    public enum Verdict: Equatable {
        case faster, slower, noDifference
    }

    public static func measure(warmUp: Int, samples: Int, _ work: () -> (operations: Int, result: Int)) -> Measurement {
        var checksum = 0
        for _ in 0..<warmUp {
            checksum &+= work().result               // warm-up: kept alive, never counted
        }
        var counts: [Int] = []
        counts.reserveCapacity(samples)
        for _ in 0..<samples {
            let run = work()
            checksum &+= run.result
            counts.append(run.operations)
        }
        counts.sort()
        return Measurement(median: counts[samples / 2], fewest: counts[0], checksum: checksum)
    }

    public static func verdict(before: [Int], after: [Int]) -> Verdict {
        func summary(_ values: [Int]) -> (median: Int, spread: Int) {
            let sorted = values.sorted()
            return (sorted[sorted.count / 2], sorted[(3 * sorted.count) / 4] - sorted[sorted.count / 4])
        }
        let old = summary(before)
        let new = summary(after)
        let gap = new.median - old.median
        if abs(gap) <= max(old.spread, new.spread) {
            return .noDifference
        }
        return gap < 0 ? .faster : .slower
    }

    public static func growthExponent(costs: [Int]) -> Double {
        let ratios = zip(costs.dropFirst(), costs).map { Double($0) / Double($1) }.sorted()
        let middle = ratios.count / 2
        let median = ratios.count.isMultiple(of: 2) ? (ratios[middle - 1] + ratios[middle]) / 2 : ratios[middle]
        return log2(median)
    }
}
