// A first-in, first-out queue (M27 · A queue with a head index).
//
// Elements live in an array. Enqueueing appends at the back; dequeueing reads the element at `head`
// and moves `head` forward, so nothing shifts. The slots before `head` are dead. Once they make up
// at least half of the array, the queue compacts: it removes them in one go and resets `head` to 0.
// Each compaction moves fewer live elements than the dequeues that created the dead slots, so the
// cost averages out to O(1) per operation, and the array is never much more than twice the size of
// the queue.

/// A first-in, first-out queue with amortised O(1) `enqueue` and `dequeue`.
///
/// ```swift
/// var line: Queue = ["Ana", "Ben"]
/// line.enqueue("Cleo")
/// line.dequeue()      // Optional("Ana")
/// line.peek()         // Optional("Ben")
/// ```
///
/// `Queue` is a value type: copies are independent, and copying is O(1) until one copy changes.
public struct Queue<Element> {
    private var storage: [Element] = []
    private var head = 0

    /// Compaction only starts once this many slots are dead, so small queues never bother.
    private static var minimumDeadSlots: Int { 16 }

    /// Creates an empty queue. O(1).
    public init() {}

    /// Creates a queue holding `elements`, with the first element at the front. O(n).
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        storage = Array(elements)
    }

    /// The number of elements waiting in the queue. O(1).
    public var count: Int {
        storage.count - head
    }

    /// True when the queue holds no elements. O(1).
    public var isEmpty: Bool {
        head == storage.count
    }

    /// Adds `element` to the back of the queue. Amortised O(1).
    public mutating func enqueue(_ element: Element) {
        storage.append(element)
    }

    /// Removes and returns the element at the front, or nil if the queue is empty. Amortised O(1).
    @discardableResult
    public mutating func dequeue() -> Element? {
        guard head < storage.count else { return nil }
        let element = storage[head]
        head += 1
        if head == storage.count {
            // Empty again: start afresh, releasing every element but keeping the capacity
            storage.removeAll(keepingCapacity: true)
            head = 0
        } else if head >= Self.minimumDeadSlots && head * 2 >= storage.count {
            // At least half the slots are dead: move the live ones to the start
            storage.removeFirst(head)
            head = 0
        }
        return element
    }

    /// Returns the element at the front without removing it, or nil if the queue is empty. O(1).
    public func peek() -> Element? {
        head < storage.count ? storage[head] : nil
    }

    /// Removes every element. O(n).
    public mutating func removeAll() {
        storage.removeAll()
        head = 0
    }
}

extension Queue: Sequence {
    /// Iterates from the front of the queue to the back, without removing anything.
    public func makeIterator() -> IndexingIterator<ArraySlice<Element>> {
        storage[head...].makeIterator()
    }

    /// The number of elements, so `Array(queue)` allocates once. O(1).
    public var underestimatedCount: Int {
        count
    }
}

extension Queue: ExpressibleByArrayLiteral {
    /// Creates a queue from an array literal, with the first element at the front. O(n).
    public init(arrayLiteral elements: Element...) {
        storage = elements
    }
}

extension Queue: CustomStringConvertible {
    /// The elements from front to back, for example `Queue([1, 2, 3])`. O(n).
    public var description: String {
        "Queue(\(Array(self)))"
    }
}

extension Queue: Equatable where Element: Equatable {
    /// Two queues are equal when they hold equal elements in the same order. O(n).
    public static func == (lhs: Queue, rhs: Queue) -> Bool {
        lhs.count == rhs.count && lhs.elementsEqual(rhs)
    }
}
