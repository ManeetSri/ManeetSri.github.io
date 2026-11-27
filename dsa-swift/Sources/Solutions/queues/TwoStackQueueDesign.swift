// Reference solution: A queue from two stacks. New elements go onto `inbox`; dequeues pop from
// `outbox`, which is refilled by pouring the whole inbox across only when it's empty. Each element
// is pushed, moved and popped at most once, so every operation is amortised O(1).

public enum TwoStackQueueDesign {
    public struct TwoStackQueue<Element> {
        private var inbox: [Element] = []     // newest on top (the end)
        private var outbox: [Element] = []    // oldest on top (the end)

        public init() {}

        public mutating func enqueue(_ element: Element) {
            inbox.append(element)
        }

        public mutating func dequeue() -> Element? {
            if outbox.isEmpty {
                while let element = inbox.popLast() {
                    outbox.append(element)    // pouring reverses the order
                }
            }
            return outbox.popLast()
        }

        public func peek() -> Element? {
            outbox.last ?? inbox.first
        }

        public var isEmpty: Bool {
            inbox.isEmpty && outbox.isEmpty
        }

        public var count: Int {
            inbox.count + outbox.count
        }
    }
}
