// Reference solution: Design a circular queue. A fixed array of optional slots, the slot of the
// front (`head`) and a count. The element at position i lives in slot (head + i) % capacity, and
// the count tells full from empty. Every operation is O(1); nothing is allocated after init.

public enum CircularQueueDesign {
    public struct CircularQueue<Element> {
        private var slots: [Element?]
        private var head = 0
        public private(set) var count = 0

        public init(capacity: Int) {
            precondition(capacity > 0, "A circular queue needs room for at least one element")
            slots = Array(repeating: nil, count: capacity)
        }

        public var capacity: Int {
            slots.count
        }

        public mutating func enqueue(_ element: Element) -> Bool {
            guard count < slots.count else { return false }
            slots[(head + count) % slots.count] = element    // the free slot right after the back
            count += 1
            return true
        }

        public mutating func dequeue() -> Element? {
            guard count > 0 else { return nil }
            let element = slots[head]
            slots[head] = nil                                // release it
            head = (head + 1) % slots.count
            count -= 1
            return element
        }

        public var front: Element? {
            count > 0 ? slots[head] : nil
        }

        public var back: Element? {
            count > 0 ? slots[(head + count - 1) % slots.count] : nil
        }

        public var isEmpty: Bool {
            count == 0
        }

        public var isFull: Bool {
            count == slots.count
        }
    }
}
