// The finished singly linked list from M25 (Build LinkedList<T>, Making LinkedList a Sequence and
// Copy-on-write and persistent lists).
//
// Why a struct with copy-on-write rather than a class? A class would be simpler, but then
// `var b = a; b.append(4)` would change `a` as well, unlike every other Swift collection. So the nodes
// live in a private `Storage` object that copies of the list share, and every mutating method first
// checks `isKnownUniquelyReferenced(&storage)`. If another copy can see the storage, the list copies its
// nodes before changing anything (M11, Writing your own copy-on-write). Copying is O(1) until the first
// change; that first change to a shared list costs O(n) to copy the nodes.
//
// Nodes never leak out of the type, so no two storages ever share a node and changing one list can never
// reach into another.

/// A singly linked list with value semantics: O(1) `prepend`, `append`, `removeFirst`, `first`, `last`
/// and `count`, and O(i) access to the element at position i.
public struct LinkedList<Element> {
    final class Node {
        var value: Element
        var next: Node?

        init(_ value: Element, next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }

    /// The nodes of one list. `tail` is a second strong reference to the last node; that isn't a cycle,
    /// because the last node points at nothing.
    final class Storage {
        var head: Node?
        var tail: Node?
        var count = 0

        init() {}

        /// A copy with brand-new nodes holding the same values. O(n).
        func copy() -> Storage {
            let result = Storage()
            var current = head
            while let node = current {
                let fresh = Node(node.value)
                if let tail = result.tail {
                    tail.next = fresh
                } else {
                    result.head = fresh
                }
                result.tail = fresh
                current = node.next
            }
            result.count = count
            return result
        }
    }

    private var storage = Storage()

    /// An empty list. O(1).
    public init() {}

    /// A list holding `elements` in order. O(n).
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            append(element)
        }
    }

    /// Gives this list its own storage if any other copy shares it. O(1), or O(n) when it copies.
    private mutating func makeUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = storage.copy()
        }
    }

    /// The number of elements. O(1): the list keeps count as it changes.
    public var count: Int { storage.count }

    /// True when the list has no elements. O(1).
    public var isEmpty: Bool { storage.head == nil }

    /// The first element, or nil if the list is empty. O(1).
    public var first: Element? { storage.head?.value }

    /// The last element, or nil if the list is empty. O(1), thanks to the tail reference.
    public var last: Element? { storage.tail?.value }

    /// Adds `value` at the front. O(1).
    public mutating func prepend(_ value: Element) {
        makeUnique()
        let node = Node(value, next: storage.head)
        storage.head = node
        if storage.tail == nil {
            storage.tail = node
        }
        storage.count += 1
    }

    /// Adds `value` at the end. O(1).
    public mutating func append(_ value: Element) {
        makeUnique()
        let node = Node(value)
        if let tail = storage.tail {
            tail.next = node
        } else {
            storage.head = node
        }
        storage.tail = node
        storage.count += 1
    }

    /// The node at `index`, which must be in `0..<count`. O(index).
    private func node(at index: Int) -> Node {
        var node = storage.head!
        for _ in 0..<index {
            node = node.next!
        }
        return node
    }

    /// Inserts `value` so that it ends up at position `index`, moving later elements back.
    /// Precondition: `0 ≤ index ≤ count`. O(index), so inserting at either end is O(1).
    public mutating func insert(_ value: Element, at index: Int) {
        precondition(index >= 0 && index <= count, "Index \(index) is out of range for insert into a list of \(count)")
        if index == 0 {
            prepend(value)
        } else if index == count {
            append(value)
        } else {
            makeUnique()
            let before = node(at: index - 1)
            before.next = Node(value, next: before.next)
            storage.count += 1
        }
    }

    /// Removes and returns the first element. Precondition: the list isn't empty. O(1).
    @discardableResult
    public mutating func removeFirst() -> Element {
        precondition(!isEmpty, "Can't remove the first element of an empty list")
        return popFirst()!
    }

    /// Removes and returns the first element, or returns nil if the list is empty. O(1).
    public mutating func popFirst() -> Element? {
        guard storage.head != nil else { return nil }
        makeUnique()
        let head = storage.head!
        storage.head = head.next
        if storage.head == nil {
            storage.tail = nil
        }
        storage.count -= 1
        return head.value
    }

    /// Removes and returns the element at `index`. Precondition: `0 ≤ index < count`. O(index).
    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        precondition(index >= 0 && index < count, "Index \(index) is out of range for a list of \(count)")
        if index == 0 {
            return removeFirst()
        }
        makeUnique()
        let before = node(at: index - 1)
        let removed = before.next!
        before.next = removed.next
        if removed === storage.tail {
            storage.tail = before
        }
        storage.count -= 1
        return removed.value
    }

    /// Removes every element. O(1) for this list; ARC frees the nodes if no other copy uses them.
    public mutating func removeAll() {
        storage = Storage()
    }

    /// The element at `index`, or nil if `index` is outside `0..<count`. O(index).
    public func element(at index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return node(at: index).value
    }

    /// Reverses the list in place by turning every `next` arrow around. O(n) time, O(1) extra space.
    public mutating func reverse() {
        makeUnique()
        var previous: Node? = nil
        var current = storage.head
        storage.tail = storage.head
        while let node = current {
            let following = node.next
            node.next = previous
            previous = node
            current = following
        }
        storage.head = previous
    }
}

extension LinkedList where Element: Equatable {
    /// The position of the first element equal to `value`, or nil if there isn't one. O(n).
    public func firstIndex(of value: Element) -> Int? {
        for (index, element) in enumerated() where element == value {
            return index
        }
        return nil
    }
}

extension LinkedList: Sequence {
    /// Walks the nodes from head to tail. It keeps the storage alive, so changing the list during a loop
    /// copies it first and the loop carries on over the old elements, exactly as with an Array.
    public struct Iterator: IteratorProtocol {
        private let storage: Storage
        private var current: Node?

        init(storage: Storage) {
            self.storage = storage
            current = storage.head
        }

        /// The next element, or nil after the last one. O(1).
        public mutating func next() -> Element? {
            guard let node = current else { return nil }
            current = node.next
            return node.value
        }
    }

    /// A fresh iterator starting at the head. O(1).
    public func makeIterator() -> Iterator {
        Iterator(storage: storage)
    }

    /// The exact count, so `Array(list)` reserves the right capacity. O(1).
    public var underestimatedCount: Int { count }
}

extension LinkedList: ExpressibleByArrayLiteral {
    /// A list written as an array literal: `let list: LinkedList = [1, 2, 3]`. O(n).
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension LinkedList: CustomStringConvertible {
    /// The chain of elements, drawn like the lessons draw nodes: `1 -> 2 -> 3 -> nil`, or `nil` when
    /// the list is empty. O(n).
    public var description: String {
        (map { String(describing: $0) } + ["nil"]).joined(separator: " -> ")
    }
}

extension LinkedList: Equatable where Element: Equatable {
    /// True when both lists hold equal elements in the same order. O(n).
    public static func == (lhs: LinkedList, rhs: LinkedList) -> Bool {
        lhs.count == rhs.count && lhs.elementsEqual(rhs)
    }
}
