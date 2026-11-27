// Reference solution: Sample a log stream. Reservoir sampling: the first `capacity` items fill the
// sample; the ith item after that (counting from 1) draws j uniformly from 0..<i and replaces
// sample[j] when j < capacity. It gets in with probability k/i and evicts a uniform member, which
// makes every item's final probability k/n. O(1) per offer, O(k) memory.

public enum LogStreamSampler {
    public final class Sampler<Element> {
        public let capacity: Int
        public private(set) var seen = 0
        public private(set) var sample: [Element] = []

        public init(capacity: Int) {
            self.capacity = capacity
            sample.reserveCapacity(capacity)
        }

        public func offer(_ item: Element, using generator: inout some RandomNumberGenerator) {
            seen += 1
            if sample.count < capacity {
                sample.append(item)                       // the first k fill the reservoir
            } else {
                let j = Int.random(in: 0..<seen, using: &generator)
                if j < capacity {
                    sample[j] = item                      // probability k / seen, a uniform slot
                }
            }
        }
    }
}
