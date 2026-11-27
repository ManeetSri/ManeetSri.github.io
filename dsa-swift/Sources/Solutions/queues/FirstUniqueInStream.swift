// Reference solution: First unique in a stream. A dictionary counts each element, and a head-index
// queue holds elements in the order they first appeared. After each arrival, repeated elements are
// dropped from the front of the queue (lazy deletion), so the front is always the answer. Each
// element is enqueued and dequeued at most once: O(1) amortised per element (on average, for the
// dictionary), O(distinct elements) space.

public enum FirstUniqueInStream {
    public struct UniqueWatcher<Element: Hashable> {
        private var counts: [Element: Int] = [:]
        private var candidates: [Element] = []      // first appearances, oldest first
        private var head = 0

        public init() {}

        public mutating func add(_ element: Element) {
            counts[element, default: 0] += 1
            if counts[element] == 1 {
                candidates.append(element)
            }
            // A repeated element at the front can never be unique again
            while head < candidates.count && counts[candidates[head], default: 0] > 1 {
                head += 1
            }
            // Release the dead prefix once it's at least half the array
            if head >= 64 && head * 2 >= candidates.count {
                candidates.removeFirst(head)
                head = 0
            }
        }

        public var firstUnique: Element? {
            head < candidates.count ? candidates[head] : nil
        }
    }
}
