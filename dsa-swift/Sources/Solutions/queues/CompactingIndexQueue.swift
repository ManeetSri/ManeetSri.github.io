// Reference solution: A head-index queue that gives memory back. Dequeue moves a head index instead of
// shifting items. When the queue empties, the array is cleared; when at least half its slots (and at
// least 16) are dead, they're removed in one go. Compaction moves at most one item per earlier dequeue,
// so every operation is O(1) amortised, and the array stays under 2 × count + 16 slots.

public enum CompactingIndexQueue {
    public struct TicketQueue<Element> {
        private var items: [Element] = []
        private var head = 0                     // the position of the front item

        public init() {}

        public var count: Int { items.count - head }

        public var isEmpty: Bool { head == items.count }

        public var slotCount: Int { items.count }

        public mutating func enqueue(_ element: Element) {
            items.append(element)
        }

        public mutating func dequeue() -> Element? {
            guard head < items.count else { return nil }
            let element = items[head]
            head += 1
            if head == items.count {
                items.removeAll(keepingCapacity: true)     // all dead: start afresh
                head = 0
            } else if head >= 16 && head * 2 >= items.count {
                items.removeFirst(head)                    // drop the dead half in one go
                head = 0
            }
            return element
        }

        public func peek() -> Element? {
            head < items.count ? items[head] : nil
        }
    }
}
