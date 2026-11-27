// Reference solution: Build a growable deque. A ring of optional slots with the front's slot
// (`head`) and a count. The element at position i is in slot (head + i) % capacity. Prepending steps
// `head` back one slot, wrapping with + capacity because Swift's % keeps the sign. When every slot is
// full, the deque doubles its slots and copies the elements across in order, so insertions are
// amortised O(1); everything else is O(1).

public enum GrowableDeque {
    public struct RingDeque<Element> {
        private var slots: [Element?] = []
        private var head = 0
        public private(set) var count = 0

        public init() {}

        private func slot(_ offset: Int) -> Int {
            (head + offset) % slots.count
        }

        // Doubles the slots, copying the elements in order so the front lands in slot 0
        private mutating func grow() {
            var bigger = [Element?](repeating: nil, count: Swift.max(8, slots.count * 2))
            for offset in 0..<count {
                bigger[offset] = slots[slot(offset)]
            }
            slots = bigger
            head = 0
        }

        public mutating func append(_ element: Element) {
            if count == slots.count { grow() }
            slots[slot(count)] = element
            count += 1
        }

        public mutating func prepend(_ element: Element) {
            if count == slots.count { grow() }
            head = (head - 1 + slots.count) % slots.count
            slots[head] = element
            count += 1
        }

        public mutating func popFirst() -> Element? {
            guard count > 0 else { return nil }
            let element = slots[head]
            slots[head] = nil
            head = slot(1)
            count -= 1
            return element
        }

        public mutating func popLast() -> Element? {
            guard count > 0 else { return nil }
            let index = slot(count - 1)
            let element = slots[index]
            slots[index] = nil
            count -= 1
            return element
        }

        public var first: Element? {
            count > 0 ? slots[head] : nil
        }

        public var last: Element? {
            count > 0 ? slots[slot(count - 1)] : nil
        }

        public var isEmpty: Bool {
            count == 0
        }

        public subscript(position: Int) -> Element? {
            guard position >= 0 && position < count else { return nil }
            return slots[slot(position)]
        }
    }
}
