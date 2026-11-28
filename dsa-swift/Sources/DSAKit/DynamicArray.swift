// DynamicArray: a growable array built from fixed-size buffers, as in M18 · Build your own
// DynamicArray. Swift's Array already does all of this; this version makes every growth visible, so
// you can watch count and capacity and reason about what each operation costs.

/// A growable, random-access array that doubles its capacity whenever it runs out of room.
///
/// Elements live in a fixed-size buffer of optionals: slots `0..<count` hold elements and the rest
/// are `nil`. When the buffer is full, `append` allocates one twice the size and copies every
/// element across, so a sequence of n appends costs O(n) in total: O(1) amortised each.
///
/// `DynamicArray` is a value type. Copies are independent (the buffer is a Swift array, so copying
/// is copy-on-write).
public struct DynamicArray<Element> {
    private var buffer: [Element?]

    /// The number of elements. O(1).
    public private(set) var count: Int

    /// Creates an empty array with no storage. O(1).
    public init() {
        buffer = []
        count = 0
    }

    /// Creates an empty array with room for at least `minimumCapacity` elements, so the first
    /// `minimumCapacity` appends never grow the buffer. O(minimumCapacity).
    public init(minimumCapacity: Int) {
        precondition(minimumCapacity >= 0, "Capacity can't be negative")
        buffer = Array(repeating: nil, count: minimumCapacity)
        count = 0
    }

    /// Creates an array holding the elements of `elements`, in order. O(n).
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        self.init()
        for element in elements {
            append(element)
        }
    }

    /// How many elements fit before the next append has to grow the buffer. O(1).
    public var capacity: Int {
        buffer.count
    }

    /// True when the array holds no elements. O(1).
    public var isEmpty: Bool {
        count == 0
    }

    /// Adds `element` at the end. O(1) amortised; O(n) when the buffer is full and doubles.
    public mutating func append(_ element: Element) {
        if count == capacity {
            resize(to: Swift.max(1, capacity * 2))
        }
        buffer[count] = element
        count += 1
    }

    /// Adds every element of `elements` at the end, in order. O(k) amortised for k new elements.
    public mutating func append<S: Sequence>(contentsOf elements: S) where S.Element == Element {
        for element in elements {
            append(element)
        }
    }

    /// Inserts `element` at `index`, shifting the elements from `index` onwards one place right.
    /// `index` may equal `count`, which appends. O(n − index), plus a possible growth.
    public mutating func insert(_ element: Element, at index: Int) {
        precondition(index >= 0 && index <= count, "Insertion index \(index) is out of range 0...\(count)")
        if count == capacity {
            resize(to: Swift.max(1, capacity * 2))
        }
        var position = count
        while position > index {
            buffer[position] = buffer[position - 1]
            position -= 1
        }
        buffer[index] = element
        count += 1
    }

    /// Removes and returns the element at `index`, shifting the later elements one place left.
    /// O(n − index). The capacity doesn't shrink.
    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        precondition(index >= 0 && index < count, "Index \(index) is out of range 0..<\(count)")
        let removed = buffer[index]!
        for position in index..<(count - 1) {
            buffer[position] = buffer[position + 1]
        }
        buffer[count - 1] = nil
        count -= 1
        return removed
    }

    /// Removes and returns the last element. The array must not be empty. O(1).
    @discardableResult
    public mutating func removeLast() -> Element {
        precondition(count > 0, "Can't remove the last element of an empty DynamicArray")
        count -= 1
        let removed = buffer[count]!
        buffer[count] = nil
        return removed
    }

    /// Removes and returns the last element, or returns nil if the array is empty. O(1).
    public mutating func popLast() -> Element? {
        isEmpty ? nil : removeLast()
    }

    /// Removes every element. Keeps the buffer when `keepingCapacity` is true, so refilling the
    /// array doesn't grow it again. O(n).
    public mutating func removeAll(keepingCapacity: Bool = false) {
        if keepingCapacity {
            for position in 0..<count {
                buffer[position] = nil
            }
        } else {
            buffer = []
        }
        count = 0
    }

    /// Grows the buffer, if needed, so it holds at least `minimumCapacity` elements. Never shrinks.
    /// O(n) when it grows, O(1) otherwise.
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        if minimumCapacity > capacity {
            resize(to: minimumCapacity)
        }
    }

    // Moves the elements into a new buffer of exactly `newCapacity` slots. O(count + newCapacity).
    private mutating func resize(to newCapacity: Int) {
        var newBuffer = [Element?](repeating: nil, count: newCapacity)
        for position in 0..<count {
            newBuffer[position] = buffer[position]
        }
        buffer = newBuffer
    }
}

extension DynamicArray: RandomAccessCollection, MutableCollection {
    /// Always 0. O(1).
    public var startIndex: Int { 0 }

    /// One past the last element: `count`. O(1).
    public var endIndex: Int { count }

    /// `i + 1`. O(1).
    public func index(after i: Int) -> Int { i + 1 }

    /// `i - 1`. O(1).
    public func index(before i: Int) -> Int { i - 1 }

    /// Reads or writes the element at `position`, which must be in `0..<count`. O(1).
    public subscript(position: Int) -> Element {
        get {
            precondition(position >= 0 && position < count, "Index \(position) is out of range 0..<\(count)")
            return buffer[position]!
        }
        set {
            precondition(position >= 0 && position < count, "Index \(position) is out of range 0..<\(count)")
            buffer[position] = newValue
        }
    }
}

extension DynamicArray: ExpressibleByArrayLiteral {
    /// Creates an array from a literal such as `[1, 2, 3]`. O(n).
    public init(arrayLiteral elements: Element...) {
        self.init(minimumCapacity: elements.count)
        for element in elements {
            append(element)
        }
    }
}

extension DynamicArray: CustomStringConvertible {
    /// The elements in square brackets, written the way Array writes them: `[1, 2, 3]` or `["a", "b"]`. O(n).
    public var description: String {
        "[" + map { String(reflecting: $0) }.joined(separator: ", ") + "]"
    }
}

extension DynamicArray: Equatable where Element: Equatable {
    /// Two arrays are equal when they hold equal elements in the same order. Capacity is ignored.
    /// O(n).
    public static func == (lhs: DynamicArray, rhs: DynamicArray) -> Bool {
        lhs.elementsEqual(rhs)
    }
}
