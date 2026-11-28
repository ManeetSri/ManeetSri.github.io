// Problem: A linked list from scratch (M25 · Build LinkedList<T>)

public enum LinkedListFromScratch {
    /// A singly linked list with a head, a tail and a count. It's a class, so copies share one list.
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

        /// An empty list.
        public init() {}

        /// A list holding `elements` in order.
        public convenience init(_ elements: [Element]) {
            self.init()
            for element in elements {
                append(element)
            }
        }

        /// The number of elements, in O(1). Turn this into a stored property that every method keeps
        /// up to date.
        public var count: Int {
            // Write your solution here, then run:
            // swift test --filter LinkedListFromScratchTests
            return 0
        }

        /// True when the list has no elements.
        public var isEmpty: Bool {
            return true
        }

        /// The first element, or nil if the list is empty.
        public var first: Element? {
            return nil
        }

        /// The last element, or nil if the list is empty, in O(1).
        public var last: Element? {
            return nil
        }

        /// Adds `value` at the end, in O(1).
        public func append(_ value: Element) {
        }

        /// Adds `value` at the front, in O(1).
        public func prepend(_ value: Element) {
        }

        /// Inserts `value` so it ends up at position `index` (0 is the front, `count` is the end) and
        /// returns true. Returns false, changing nothing, if `index` is outside `0...count`.
        @discardableResult
        public func insert(_ value: Element, at index: Int) -> Bool {
            return false
        }

        /// Removes and returns the first element, or returns nil if the list is empty.
        @discardableResult
        public func removeFirst() -> Element? {
            return nil
        }

        /// Removes and returns the element at `index`, or returns nil, changing nothing, if `index` is
        /// outside `0..<count`.
        @discardableResult
        public func remove(at index: Int) -> Element? {
            return nil
        }

        /// The element at `index`, or nil if `index` is outside `0..<count`.
        public func value(at index: Int) -> Element? {
            return nil
        }

        /// Reverses the list in place, without creating any nodes.
        public func reverse() {
        }

        /// Walks the list from head to tail, one node per call to `next()`.
        public struct Iterator: IteratorProtocol {
            var current: Node?

            public mutating func next() -> Element? {
                return nil
            }
        }

        /// A fresh iterator that starts at the head.
        public func makeIterator() -> Iterator {
            Iterator(current: head)
        }
    }
}

extension LinkedListFromScratch.List where Element: Equatable {
    /// The position of the first element equal to `value`, or nil if there isn't one.
    public func firstIndex(of value: Element) -> Int? {
        return nil
    }

    /// Removes every element equal to `value` and returns how many were removed.
    @discardableResult
    public func removeAll(equalTo value: Element) -> Int {
        return 0
    }
}
