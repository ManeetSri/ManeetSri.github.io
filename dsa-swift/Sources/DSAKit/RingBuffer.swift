// A fixed-capacity ring buffer (M27 · Ring buffers).
//
// The buffer owns `capacity` slots, allocated once. `head` is the slot holding the oldest element
// and `count` says how many slots are in use, so the element at position i lives in slot
// (head + i) % capacity, and keeping a count tells a full buffer from an empty one.
//
// When the buffer is full, `append` OVERWRITES THE OLDEST ELEMENT and returns it. That's the
// behaviour you want for "the last N things": recent log lines, the last few sensor readings, the
// frame times behind an FPS counter. If you'd rather refuse new elements when full, check `isFull`
// before appending.

/// A queue with a fixed capacity that never allocates after it's created. When it's full,
/// appending overwrites (and returns) the oldest element.
///
/// ```swift
/// var recent = RingBuffer<String>(capacity: 2)
/// recent.append("boot")
/// recent.append("login")
/// recent.append("sync")      // full, so "boot" is overwritten and returned
/// Array(recent)              // ["login", "sync"]
/// ```
///
/// Position 0 is the oldest element and position `count - 1` the newest.
public struct RingBuffer<Element> {
    private var slots: [Element?]
    private var head = 0

    /// The number of elements in the buffer. O(1).
    public private(set) var count = 0

    /// Creates an empty buffer with room for `capacity` elements. O(capacity).
    /// - Precondition: `capacity` is at least 1.
    public init(capacity: Int) {
        precondition(capacity > 0, "A ring buffer needs a capacity of at least 1")
        slots = Array(repeating: nil, count: capacity)
    }

    /// Creates a buffer with room for `capacity` elements and appends `elements` in order. If there
    /// are more than `capacity` of them, only the last `capacity` are kept. O(capacity + n).
    public init<S: Sequence>(capacity: Int, _ elements: S) where S.Element == Element {
        self.init(capacity: capacity)
        for element in elements {
            append(element)
        }
    }

    /// The most elements the buffer can hold. O(1).
    public var capacity: Int {
        slots.count
    }

    /// True when the buffer holds no elements. O(1).
    public var isEmpty: Bool {
        count == 0
    }

    /// True when every slot is in use, so the next `append` overwrites the oldest element. O(1).
    public var isFull: Bool {
        count == slots.count
    }

    /// The slot that holds position `offset`, wrapping past the end of `slots`.
    private func slot(_ offset: Int) -> Int {
        (head + offset) % slots.count
    }

    /// Adds `element` as the newest element. O(1).
    ///
    /// - Returns: nil if there was room. If the buffer was full, the oldest element, which has
    ///   been overwritten.
    @discardableResult
    public mutating func append(_ element: Element) -> Element? {
        if isFull {
            let oldest = slots[head]
            slots[head] = element                // the newest takes the oldest's slot…
            head = (head + 1) % slots.count      // …and the next oldest becomes the front
            return oldest
        }
        slots[slot(count)] = element
        count += 1
        return nil
    }

    /// Removes and returns the oldest element, or nil if the buffer is empty. O(1).
    @discardableResult
    public mutating func popFirst() -> Element? {
        guard count > 0 else { return nil }
        let oldest = slots[head]
        slots[head] = nil                        // release it
        head = (head + 1) % slots.count
        count -= 1
        return oldest
    }

    /// Removes and returns the newest element, or nil if the buffer is empty. O(1).
    @discardableResult
    public mutating func popLast() -> Element? {
        guard count > 0 else { return nil }
        let index = slot(count - 1)
        let newest = slots[index]
        slots[index] = nil
        count -= 1
        return newest
    }

    /// The oldest element, or nil if the buffer is empty. O(1).
    public var first: Element? {
        count > 0 ? slots[head] : nil
    }

    /// The newest element, or nil if the buffer is empty. O(1).
    public var last: Element? {
        count > 0 ? slots[slot(count - 1)] : nil
    }

    /// The element at `position`, where 0 is the oldest. O(1).
    /// - Precondition: `0 <= position < count`.
    public subscript(position: Int) -> Element {
        get {
            precondition(position >= 0 && position < count, "RingBuffer index out of range")
            return slots[slot(position)]!
        }
        set {
            precondition(position >= 0 && position < count, "RingBuffer index out of range")
            slots[slot(position)] = newValue
        }
    }

    /// Removes every element, keeping the capacity. O(capacity).
    public mutating func removeAll() {
        slots = Array(repeating: nil, count: slots.count)
        head = 0
        count = 0
    }
}

extension RingBuffer: Sequence {
    /// Iterates from the oldest element to the newest, without removing anything.
    public struct Iterator: IteratorProtocol {
        private let buffer: RingBuffer
        private var position = 0

        fileprivate init(_ buffer: RingBuffer) {
            self.buffer = buffer
        }

        public mutating func next() -> Element? {
            guard position < buffer.count else { return nil }
            defer { position += 1 }
            return buffer[position]
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(self)
    }

    /// The number of elements, so `Array(buffer)` allocates once. O(1).
    public var underestimatedCount: Int {
        count
    }
}

extension RingBuffer: CustomStringConvertible {
    /// The elements from oldest to newest and the capacity, for example
    /// `RingBuffer([1, 2, 3], capacity: 4)`. O(n).
    public var description: String {
        "RingBuffer(\(Array(self)), capacity: \(capacity))"
    }
}

extension RingBuffer: Equatable where Element: Equatable {
    /// Two buffers are equal when they have the same capacity and hold equal elements in the same
    /// order. Where those elements sit in the slots doesn't matter. O(n).
    public static func == (lhs: RingBuffer, rhs: RingBuffer) -> Bool {
        lhs.capacity == rhs.capacity && lhs.count == rhs.count && lhs.elementsEqual(rhs)
    }
}
