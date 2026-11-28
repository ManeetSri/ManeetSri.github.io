// A double-ended queue on a growable ring buffer (M27 · Build Deque<T>).
//
// Elements live in a ring of slots: `head` is the slot of the first element, and the element at
// position i lives in slot head + i, wrapping round past the end. Adding at either end writes one
// slot and moves `head` or the count, so both ends are O(1). When every slot is full, the deque
// doubles its slots and copies the elements across in order, which (as with Array) averages out to
// O(1) per insertion.
//
// For production code, the swift-collections package has a `Deque` built on the same idea.

/// A double-ended queue: amortised O(1) `append` and `prepend`, O(1) `popFirst` and `popLast`, and
/// O(1) access by position.
///
/// ```swift
/// var history: Deque = [2, 3]
/// history.prepend(1)          // [1, 2, 3]
/// history.append(4)           // [1, 2, 3, 4]
/// history.popFirst()          // Optional(1)
/// history[0]                  // 2
/// ```
///
/// `Deque` is a value type and a `RandomAccessCollection`, so `for`-`in`, `map`, `first`, `last`
/// and `reversed()` all work, with position 0 at the front.
public struct Deque<Element> {
    private var slots: [Element?] = []
    private var head = 0

    /// The number of elements in the deque. O(1).
    public private(set) var count = 0

    /// The smallest number of slots allocated once the deque holds anything.
    private static var minimumCapacity: Int { 8 }

    /// Creates an empty deque. O(1).
    public init() {}

    /// Creates a deque holding `elements`, with the first element at the front. O(n).
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        slots = elements.map { Optional($0) }
        count = slots.count
    }

    /// How many elements the deque can hold before it next grows. O(1).
    public var capacity: Int {
        slots.count
    }

    /// The slot holding position `offset`. Both values are below `capacity`, so their sum is below
    /// twice the capacity and one subtraction wraps it.
    private func slot(_ offset: Int) -> Int {
        let index = head + offset
        return index >= slots.count ? index - slots.count : index
    }

    /// Doubles the number of slots, copying the elements across so the front is in slot 0.
    /// O(n), but rare enough to be amortised O(1) per insertion.
    private mutating func grow() {
        var bigger = [Element?](repeating: nil, count: Swift.max(Self.minimumCapacity, slots.count * 2))
        for offset in 0..<count {
            bigger[offset] = slots[slot(offset)]
        }
        slots = bigger
        head = 0
    }

    /// Adds `element` at the back. Amortised O(1).
    public mutating func append(_ element: Element) {
        if count == slots.count { grow() }
        slots[slot(count)] = element
        count += 1
    }

    /// Adds `element` at the front. Amortised O(1).
    public mutating func prepend(_ element: Element) {
        if count == slots.count { grow() }
        head = head == 0 ? slots.count - 1 : head - 1
        slots[head] = element
        count += 1
    }

    /// Removes and returns the front element, or nil if the deque is empty. O(1).
    @discardableResult
    public mutating func popFirst() -> Element? {
        guard count > 0 else { return nil }
        let element = slots[head]
        slots[head] = nil                        // release it
        head = slot(1)
        count -= 1
        return element
    }

    /// Removes and returns the back element, or nil if the deque is empty. O(1).
    @discardableResult
    public mutating func popLast() -> Element? {
        guard count > 0 else { return nil }
        let index = slot(count - 1)
        let element = slots[index]
        slots[index] = nil
        count -= 1
        return element
    }

    /// Removes every element. With `keepingCapacity`, the slots stay allocated for reuse. O(n).
    public mutating func removeAll(keepingCapacity: Bool = false) {
        if keepingCapacity {
            slots = [Element?](repeating: nil, count: slots.count)
        } else {
            slots = []
        }
        head = 0
        count = 0
    }
}

extension Deque: RandomAccessCollection, MutableCollection {
    /// Always 0: positions count from the front. O(1).
    public var startIndex: Int { 0 }

    /// The number of elements, one past the last valid position. O(1).
    public var endIndex: Int { count }

    /// The element at `position`, where 0 is the front. O(1).
    /// - Precondition: `0 <= position < count`.
    public subscript(position: Int) -> Element {
        get {
            precondition(position >= 0 && position < count, "Deque index out of range")
            return slots[slot(position)]!
        }
        set {
            precondition(position >= 0 && position < count, "Deque index out of range")
            slots[slot(position)] = newValue
        }
    }

    /// True when the deque holds no elements. O(1).
    public var isEmpty: Bool {
        count == 0
    }
}

extension Deque: ExpressibleByArrayLiteral {
    /// Creates a deque from an array literal, with the first element at the front. O(n).
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension Deque: CustomStringConvertible {
    /// The elements from front to back, for example `Deque([1, 2, 3])`. O(n).
    public var description: String {
        "Deque(\(Array(self)))"
    }
}

extension Deque: Equatable where Element: Equatable {
    /// Two deques are equal when they hold equal elements in the same order. Where those elements
    /// sit in the slots doesn't matter. O(n).
    public static func == (lhs: Deque, rhs: Deque) -> Bool {
        lhs.count == rhs.count && lhs.elementsEqual(rhs)
    }
}

extension Deque: Hashable where Element: Hashable {
    /// Hashes the elements in order, so equal deques hash equally. O(n).
    public func hash(into hasher: inout Hasher) {
        hasher.combine(count)
        for element in self {
            hasher.combine(element)
        }
    }
}
