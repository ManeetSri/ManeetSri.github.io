// Reference solution: A linked list from scratch. A class holding head, tail and count. The tail makes
// append O(1), the count makes count O(1), and a dummy node removes the head special case from
// removeAll(equalTo:). Every operation that removes the last node moves the tail back.

public enum LinkedListFromScratch {
    public final class List<Element>: Sequence {
        final class Node {
            var value: Element
            var next: Node?

            init(_ value: Element, next: Node? = nil) {
                self.value = value
                self.next = next
            }
        }

        var head: Node?
        var tail: Node?
        public private(set) var count = 0

        public init() {}

        public convenience init(_ elements: [Element]) {
            self.init()
            for element in elements {
                append(element)
            }
        }

        public var isEmpty: Bool { head == nil }

        public var first: Element? { head?.value }

        public var last: Element? { tail?.value }

        public func append(_ value: Element) {
            let node = Node(value)
            if let tail {
                tail.next = node
            } else {
                head = node
            }
            tail = node
            count += 1
        }

        public func prepend(_ value: Element) {
            head = Node(value, next: head)
            if tail == nil {
                tail = head
            }
            count += 1
        }

        /// The node at `index`, which the caller has checked is in 0..<count.
        private func node(at index: Int) -> Node {
            var node = head!
            for _ in 0..<index {
                node = node.next!
            }
            return node
        }

        @discardableResult
        public func insert(_ value: Element, at index: Int) -> Bool {
            guard index >= 0 && index <= count else { return false }
            if index == 0 {
                prepend(value)
            } else if index == count {
                append(value)
            } else {
                let before = node(at: index - 1)
                before.next = Node(value, next: before.next)
                count += 1
            }
            return true
        }

        @discardableResult
        public func removeFirst() -> Element? {
            guard let first = head else { return nil }
            head = first.next
            if head == nil {
                tail = nil
            }
            count -= 1
            return first.value
        }

        @discardableResult
        public func remove(at index: Int) -> Element? {
            guard index >= 0 && index < count else { return nil }
            if index == 0 {
                return removeFirst()
            }
            let before = node(at: index - 1)
            let removed = before.next!
            before.next = removed.next
            if removed === tail {
                tail = before
            }
            count -= 1
            return removed.value
        }

        public func value(at index: Int) -> Element? {
            guard index >= 0 && index < count else { return nil }
            return node(at: index).value
        }

        public func reverse() {
            var previous: Node? = nil
            var current = head
            tail = head
            while let node = current {
                let following = node.next
                node.next = previous
                previous = node
                current = following
            }
            head = previous
        }

        public struct Iterator: IteratorProtocol {
            var current: Node?

            public mutating func next() -> Element? {
                guard let node = current else { return nil }
                current = node.next
                return node.value
            }
        }

        public func makeIterator() -> Iterator {
            Iterator(current: head)
        }
    }
}

extension LinkedListFromScratch.List where Element: Equatable {
    public func firstIndex(of value: Element) -> Int? {
        var index = 0
        var current = head
        while let node = current {
            if node.value == value {
                return index
            }
            index += 1
            current = node.next
        }
        return nil
    }

    @discardableResult
    public func removeAll(equalTo value: Element) -> Int {
        guard let first = head else { return 0 }
        // A dummy node in front of the head: every real node now has a node before it.
        let dummy = Node(first.value, next: head)
        var previous = dummy
        var removed = 0
        while let node = previous.next {
            if node.value == value {
                previous.next = node.next
                removed += 1
            } else {
                previous = node
            }
        }
        head = dummy.next
        tail = head == nil ? nil : previous
        count -= removed
        return removed
    }
}
