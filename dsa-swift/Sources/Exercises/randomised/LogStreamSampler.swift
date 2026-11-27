// Problem: Sample a log stream (M67 · Reservoir sampling)

public enum LogStreamSampler {
    /// Keeps a uniform random sample of at most `capacity` of the items offered so far, storing only
    /// those items. Until `capacity` items have been offered, the sample holds every item in order.
    /// Draw every random number from the generator passed to `offer`.
    public final class Sampler<Element> {
        // Write your solution here, then run:
        // swift test --filter LogStreamSamplerTests
        // Add the private storage you need.

        /// The most items the sample holds. At least 1.
        public let capacity: Int

        public init(capacity: Int) {
            self.capacity = capacity
        }

        /// How many items have been offered.
        public var seen: Int {
            return 0
        }

        /// The current sample: every item so far if fewer than `capacity` were offered, otherwise
        /// `capacity` of them, in any order.
        public var sample: [Element] {
            return []
        }

        /// Offers the next item of the stream. Aim for O(1).
        public func offer(_ item: Element, using generator: inout some RandomNumberGenerator) {
        }
    }
}
