// Generated from src/dsa/content/lessons/stacks/stack-build.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A last-in, first-out stack. The top is the end of the array.
struct Stack<Element> {
    private var storage: [Element] = []

    init() {}

    /// Puts an element on top. Amortised O(1).
    mutating func push(_ element: Element) {
        storage.append(element)
    }

    /// Removes and returns the top element, or nil if empty. O(1).
    @discardableResult
    mutating func pop() -> Element? {
        storage.popLast()
    }

    /// The top element without removing it, or nil if empty. O(1).
    func peek() -> Element? {
        storage.last
    }

    var isEmpty: Bool { storage.isEmpty }
    var count: Int { storage.count }
}

extension Stack: ExpressibleByArrayLiteral {
    /// Elements are listed bottom to top: in [1, 2, 3], 3 is on top.
    init(arrayLiteral elements: Element...) {
        storage = elements
    }
}

extension Stack: Sequence {
    /// Iterates from the top down, the order pop() would return them.
    func makeIterator() -> ReversedCollection<[Element]>.Iterator {
        storage.reversed().makeIterator()
    }
}

extension Stack: CustomStringConvertible {
    var description: String {
        storage.isEmpty ? "Stack (empty)" : "Stack " + storage.map { "\($0)" }.joined(separator: " | ") + " <- top"
    }
}

extension Stack: Equatable where Element: Equatable {}

var plates: Stack = [4, 8, 15]
plates.push(16)
print(plates)
print(plates.pop() ?? -1, plates.peek() ?? -1, plates.count)
print(Array(plates))
print(plates.map { $0 * 2 })
print(plates.contains(8), plates.max() ?? 0)
print(plates == [4, 8, 15])
plates.pop()
plates.pop()
plates.pop()
print(plates, plates.isEmpty, plates.pop() == nil)
