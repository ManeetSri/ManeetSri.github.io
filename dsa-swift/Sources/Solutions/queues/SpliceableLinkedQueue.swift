// Reference solution: Merge two linked queues in O(1). A singly linked queue with head, tail and count.
// Absorbing links this queue's tail to the other's head, takes over its tail and count, and resets the
// other queue so it forgets the nodes it gave away. Every operation is O(1) in the worst case.

public enum SpliceableLinkedQueue {
    public final class LinkedQueue<Element> {
        private final class Node {
            let value: Element
            var next: Node?
            init(_ value: Element) { self.value = value }
        }

        private var head: Node?                  // the front: dequeue here
        private var tail: Node?                  // the back: enqueue here
        public private(set) var count = 0

        public init() {}

        deinit {
            // Unlink the nodes one at a time, so freeing a long queue doesn't recurse node by node
            var node = head
            head = nil
            tail = nil
            while let current = node {
                node = current.next
                current.next = nil
            }
        }

        public var isEmpty: Bool { head == nil }

        public func enqueue(_ element: Element) {
            let node = Node(element)
            if let tail {
                tail.next = node
            } else {
                head = node                      // empty queue: it's also the front
            }
            tail = node
            count += 1
        }

        public func dequeue() -> Element? {
            guard let front = head else { return nil }
            head = front.next
            if head == nil {
                tail = nil                       // that was the last node
            }
            count -= 1
            return front.value
        }

        public func peek() -> Element? {
            head?.value
        }

        public var values: [Element] {
            var result: [Element] = []
            var node = head
            while let current = node {
                result.append(current.value)
                node = current.next
            }
            return result
        }

        public func absorb(_ other: LinkedQueue<Element>) {
            guard other !== self, let otherHead = other.head else { return }
            if let tail {
                tail.next = otherHead
            } else {
                head = otherHead
            }
            tail = other.tail
            count += other.count
            other.head = nil                     // other must forget the nodes it gave away
            other.tail = nil
            other.count = 0
        }
    }
}
