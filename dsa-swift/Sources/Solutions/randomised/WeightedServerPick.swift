// Reference solution: Weighted server picker. The prefix sums of the weights mark where each server's
// stretch of the number line 0..<total ends. Draw r uniformly from 0..<total and binary search for the
// first prefix sum greater than r: that server's stretch contains r. Zero weights own empty stretches
// and are never found. O(n) to build, O(log n) per pick, O(n) space.

public enum WeightedServerPick {
    public final class Picker {
        private let prefix: [Int]            // prefix[i] = weights[0] + ... + weights[i]

        public init(weights: [Int]) {
            var running = 0
            prefix = weights.map { weight in
                running += weight
                return running
            }
        }

        public func pick(using generator: inout some RandomNumberGenerator) -> Int {
            let r = Int.random(in: 0..<prefix[prefix.count - 1], using: &generator)
            var low = 0
            var high = prefix.count - 1
            while low < high {               // the first index with prefix > r
                let mid = low + (high - low) / 2
                if prefix[mid] > r {
                    high = mid
                } else {
                    low = mid + 1
                }
            }
            return low
        }
    }
}
