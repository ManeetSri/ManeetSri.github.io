// Reference solution: Moving average of a stream. The last windowSize values sit in a ring buffer
// that overwrites its oldest slot, alongside an exact Int running sum: each new value is added, and
// the value it overwrites is subtracted. O(1) time per value and O(windowSize) space.

public enum StreamMovingAverage {
    public struct MovingAverage {
        private var window: [Int]
        private var head = 0              // the slot of the oldest value
        private var count = 0
        private var sum = 0

        public init(windowSize: Int) {
            precondition(windowSize > 0, "The window must hold at least one value")
            window = Array(repeating: 0, count: windowSize)
        }

        public mutating func next(_ value: Int) -> Double {
            if count == window.count {
                sum -= window[head]                       // the oldest value leaves…
                window[head] = value                      // …and the new one takes its slot
                head = (head + 1) % window.count
            } else {
                window[(head + count) % window.count] = value
                count += 1
            }
            sum += value
            return Double(sum) / Double(count)
        }
    }
}
