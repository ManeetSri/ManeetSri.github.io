// Reference solution: A stack from queues. Push enqueues onto `main` and remembers the element as the
// top. Pop moves all but the newest element across to `helper`, noting the last one moved as the new
// top, takes the newest, and swaps the queues. O(1) push and top, O(n) pop.

import DSAKit

public enum QueueBuiltStack {
    public struct QueueStack<Element> {
        private var main = Queue<Element>()
        private var helper = Queue<Element>()
        private var newest: Element?             // the top, so top() is O(1)

        public init() {}

        public var count: Int { main.count }

        public var isEmpty: Bool { main.isEmpty }

        public mutating func push(_ element: Element) {
            main.enqueue(element)
            newest = element
        }

        public mutating func pop() -> Element? {
            guard !main.isEmpty else { return nil }
            newest = nil
            while main.count > 1 {
                let element = main.dequeue()!
                helper.enqueue(element)
                newest = element                 // the last one moved will be the new top
            }
            let popped = main.dequeue()
            swap(&main, &helper)
            return popped
        }

        public func top() -> Element? {
            newest
        }
    }
}
