// A last-in, first-out stack. The top is the end of a private array, so push and pop never shift
// the other elements. Built in M26, "Build Stack<T>", growing the M10 version into a finished type.

/// A generic last-in, first-out stack.
///
/// ```swift
/// var stack: Stack = [1, 2, 3]   // 3 is on top
/// stack.push(4)
/// print(stack.pop() ?? 0)        // 4
/// print(Array(stack))            // [3, 2, 1]: iteration goes from the top down
/// ```
///
/// It's a value type: copying a stack gives an independent stack.
public struct Stack<Element> {
    private var storage: [Element]

    /// Creates an empty stack. O(1).
    public init() {
        storage = []
    }

    /// Creates a stack holding `elements`, pushed in order, so the last one ends up on top. O(n).
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        storage = Array(elements)
    }

    /// Puts `element` on top. Amortised O(1): the array occasionally grows.
    public mutating func push(_ element: Element) {
        storage.append(element)
    }

    /// Removes and returns the top element, or returns `nil` if the stack is empty. O(1).
    @discardableResult
    public mutating func pop() -> Element? {
        storage.popLast()
    }

    /// The top element without removing it, or `nil` if the stack is empty. O(1).
    public func peek() -> Element? {
        storage.last
    }

    /// The top element, or `nil` if the stack is empty. The same as `peek()`. O(1).
    public var top: Element? {
        storage.last
    }

    /// Whether the stack has no elements. O(1).
    public var isEmpty: Bool {
        storage.isEmpty
    }

    /// The number of elements. O(1).
    public var count: Int {
        storage.count
    }

    /// Removes every element. Keeping the capacity avoids reallocating if the stack will fill up
    /// again. O(n).
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        storage.removeAll(keepingCapacity: keepCapacity)
    }

    /// Makes room for at least `minimumCapacity` elements, so that many pushes never reallocate.
    /// O(n).
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        storage.reserveCapacity(minimumCapacity)
    }
}

extension Stack: ExpressibleByArrayLiteral {
    /// Creates a stack from a literal listed bottom to top: in `[1, 2, 3]`, 3 is on top. O(n).
    public init(arrayLiteral elements: Element...) {
        storage = elements
    }
}

extension Stack: Sequence {
    /// Iterating goes from the top down: the order `pop()` would return the elements, without
    /// removing them.
    public typealias Iterator = ReversedCollection<[Element]>.Iterator

    /// An iterator from the top element to the bottom one. O(1).
    public func makeIterator() -> Iterator {
        storage.reversed().makeIterator()
    }

    /// The number of elements, so `Array(stack)` allocates once. O(1).
    public var underestimatedCount: Int {
        storage.count
    }
}

extension Stack: CustomStringConvertible {
    /// Bottom to top with the top marked, such as `Stack 4 | 8 | 15 <- top`, or `Stack (empty)`.
    /// O(n).
    public var description: String {
        if storage.isEmpty {
            return "Stack (empty)"
        }
        return "Stack " + storage.map { "\($0)" }.joined(separator: " | ") + " <- top"
    }
}

extension Stack: Equatable where Element: Equatable {}

extension Stack: Hashable where Element: Hashable {}
