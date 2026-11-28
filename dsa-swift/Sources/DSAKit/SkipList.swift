// A sorted set built as a skip list (M64 · Skip lists).
//
// Level 1 is a sorted linked list of every element; each higher level holds a random subset of the one
// below, chosen by coin flips when an element is inserted, so about half the nodes reach level 2, a
// quarter level 3, and so on. A search rides the highest level until the next element would overshoot,
// then drops a level: about 2 log₂ n steps on average, for any insertion order, with no rotations.
//
// The nodes live in arrays and link to each other by index, so the struct has value semantics through
// the arrays' own copy-on-write, and freeing a long list never recurses. The coin flips come from a
// seeded generator, so a given seed builds the same structure on every run: what tests need. In
// production code that faces untrusted input, choose an unpredictable seed.

/// A sorted set stored as a skip list: O(log n) expected insert, remove and contains, O(log n) floor,
/// ceiling, predecessor and successor, and range queries in O(log n + k) for k results.
///
/// ```swift
/// var scores = SkipList<Int>(seed: 42)
/// scores.insert(70)
/// scores.insert(85)
/// scores.insert(60)
/// scores.ceiling(80)                      // Optional(85)
/// scores.elements(in: 65...90)            // [70, 85]
/// print(Array(scores))                    // [60, 70, 85]
/// ```
public struct SkipList<Element: Comparable> {
    /// The tallest a node can be. 32 levels are plenty for billions of elements.
    public static var maxHeight: Int { 32 }

    /// SplitMix64: a small, fast, seeded generator. Each output's lowest bit is one coin flip.
    struct CoinFlips {
        var state: UInt64

        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    // Node 0 is the head sentinel, as tall as maxHeight. links[node][level] is the index of the next node
    // on that level, or -1 at the end. Removed nodes' slots are recycled through `freeSlots`.
    var values: [Element?]
    var links: [[Int]]
    var freeSlots: [Int] = []
    var generator: CoinFlips

    /// The number of levels in use: the height of the tallest node, and at least 1. O(1).
    public private(set) var height = 1

    /// The number of elements. O(1).
    public private(set) var count = 0

    /// Creates an empty set whose coin flips come from `seed`. The same seed and the same operations
    /// always build the same structure. O(1).
    public init(seed: UInt64 = 0x5EED_0F_5C1F) {
        values = [nil]
        links = [Array(repeating: -1, count: Self.maxHeight)]
        generator = CoinFlips(state: seed)
    }

    /// Creates a set holding the distinct elements of `elements`. O(n log n) expected.
    public init<S: Sequence>(_ elements: S, seed: UInt64 = 0x5EED_0F_5C1F) where S.Element == Element {
        self.init(seed: seed)
        for element in elements {
            insert(element)
        }
    }

    /// True when the set is empty. O(1).
    public var isEmpty: Bool {
        count == 0
    }

    // MARK: Walking the levels

    private func value(_ node: Int) -> Element {
        values[node]!
    }

    /// The last node on each level in use whose element is less than `element` (or, with `inclusive`,
    /// at most `element`). The head stands for "nothing smaller". O(log n) expected.
    private func predecessors(of element: Element, inclusive: Bool = false) -> [Int] {
        var result = Array(repeating: 0, count: height)
        var current = 0
        for level in stride(from: height - 1, through: 0, by: -1) {
            while true {
                let next = links[current][level]
                guard next >= 0 else { break }
                let candidate = value(next)
                guard inclusive ? candidate <= element : candidate < element else { break }
                current = next
            }
            result[level] = current
        }
        return result
    }

    /// The last node whose element is less than (or at most) `element`, on level 1. O(log n) expected.
    private func lastNode(before element: Element, inclusive: Bool) -> Int {
        var current = 0
        for level in stride(from: height - 1, through: 0, by: -1) {
            while true {
                let next = links[current][level]
                guard next >= 0 else { break }
                let candidate = value(next)
                guard inclusive ? candidate <= element : candidate < element else { break }
                current = next
            }
        }
        return current
    }

    private mutating func randomHeight() -> Int {
        var result = 1
        while result < Self.maxHeight && generator.next() & 1 == 1 {
            result += 1
        }
        return result
    }

    // MARK: Changing the set

    /// Inserts `element` if it isn't there. Returns true if it was inserted, false if an equal element
    /// was already present. O(log n) expected.
    @discardableResult
    public mutating func insert(_ element: Element) -> Bool {
        var before = predecessors(of: element)
        let next = links[before[0]][0]
        if next >= 0 && value(next) == element { return false }
        let nodeHeight = randomHeight()
        while before.count < nodeHeight {
            before.append(0)                        // levels above the old height start at the head
        }
        height = Swift.max(height, nodeHeight)          // not the Sequence method
        var nodeLinks = Array(repeating: -1, count: nodeHeight)
        for level in 0..<nodeHeight {
            nodeLinks[level] = links[before[level]][level]
        }
        let node: Int
        if let slot = freeSlots.popLast() {
            node = slot
            values[node] = element
            links[node] = nodeLinks
        } else {
            node = values.count
            values.append(element)
            links.append(nodeLinks)
        }
        for level in 0..<nodeHeight {
            links[before[level]][level] = node
        }
        count += 1
        return true
    }

    /// Removes `element`, returning the stored element equal to it, or nil if there wasn't one.
    /// O(log n) expected.
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        let before = predecessors(of: element)
        let node = links[before[0]][0]
        guard node >= 0, value(node) == element else { return nil }
        for level in 0..<links[node].count {
            links[before[level]][level] = links[node][level]
        }
        let removed = values[node]
        values[node] = nil
        links[node] = []
        freeSlots.append(node)
        while height > 1 && links[0][height - 1] < 0 {
            height -= 1
        }
        count -= 1
        return removed
    }

    /// Removes every element, keeping the generator's current state. O(n) to release the storage.
    public mutating func removeAll() {
        values = [nil]
        links = [Array(repeating: -1, count: Self.maxHeight)]
        freeSlots = []
        height = 1
        count = 0
    }

    // MARK: Lookups

    /// True if the set contains an element equal to `element`. O(log n) expected.
    public func contains(_ element: Element) -> Bool {
        let next = links[lastNode(before: element, inclusive: false)][0]
        return next >= 0 && value(next) == element
    }

    /// The smallest element, or nil when empty. O(1).
    public var first: Element? {
        let node = links[0][0]
        return node >= 0 ? values[node] : nil
    }

    /// The largest element, or nil when empty. O(log n) expected: ride each level to its end.
    public var last: Element? {
        var current = 0
        for level in stride(from: height - 1, through: 0, by: -1) {
            while links[current][level] >= 0 {
                current = links[current][level]
            }
        }
        return current == 0 ? nil : values[current]
    }

    /// Removes and returns the smallest element, or nil when empty. O(log n) expected.
    @discardableResult
    public mutating func popFirst() -> Element? {
        guard let smallest = first else { return nil }
        return remove(smallest)
    }

    /// The largest element ≤ `element`, or nil if there's none. O(log n) expected.
    public func floor(_ element: Element) -> Element? {
        let node = lastNode(before: element, inclusive: true)
        return node == 0 ? nil : values[node]
    }

    /// The smallest element ≥ `element`, or nil if there's none. O(log n) expected.
    public func ceiling(_ element: Element) -> Element? {
        let next = links[lastNode(before: element, inclusive: false)][0]
        return next >= 0 ? values[next] : nil
    }

    /// The largest element strictly less than `element`, or nil if there's none. O(log n) expected.
    public func predecessor(of element: Element) -> Element? {
        let node = lastNode(before: element, inclusive: false)
        return node == 0 ? nil : values[node]
    }

    /// The smallest element strictly greater than `element`, or nil if there's none. O(log n) expected.
    public func successor(of element: Element) -> Element? {
        let next = links[lastNode(before: element, inclusive: true)][0]
        return next >= 0 ? values[next] : nil
    }

    /// The elements in `range`, in increasing order: one search, then a walk along level 1.
    /// O(log n + k) for k results.
    public func elements(in range: ClosedRange<Element>) -> [Element] {
        var result: [Element] = []
        var node = links[lastNode(before: range.lowerBound, inclusive: false)][0]
        while node >= 0, let element = values[node], element <= range.upperBound {
            result.append(element)
            node = links[node][0]
        }
        return result
    }

    /// The elements in the half-open `range`, in increasing order. O(log n + k) for k results.
    public func elements(in range: Range<Element>) -> [Element] {
        var result: [Element] = []
        var node = links[lastNode(before: range.lowerBound, inclusive: false)][0]
        while node >= 0, let element = values[node], element < range.upperBound {
            result.append(element)
            node = links[node][0]
        }
        return result
    }

    /// How many nodes are on each level, from level 1 up to `height`. Used by the tests. O(n).
    var levelSizes: [Int] {
        (0..<height).map { level in
            var size = 0
            var node = links[0][level]
            while node >= 0 {
                size += 1
                node = links[node][level]
            }
            return size
        }
    }

    /// True when every level is sorted and holds a subset of the level below. Used by the tests. O(n).
    var isConsistent: Bool {
        var below = Set<Int>()
        for level in 0..<height {
            var seen = Set<Int>()
            var previous: Element?
            var node = links[0][level]
            while node >= 0 {
                guard let element = values[node], links[node].count > level else { return false }
                if let previous, !(previous < element) { return false }
                if level > 0 && !below.contains(node) { return false }
                seen.insert(node)
                previous = element
                node = links[node][level]
            }
            if level == 0 && seen.count != count { return false }
            below = seen
        }
        return true
    }
}

extension SkipList: Sequence {
    /// Visits the elements in increasing order, along level 1.
    public struct Iterator: IteratorProtocol {
        let values: [Element?]
        let links: [[Int]]
        var node: Int

        /// The next element in increasing order, or nil at the end. O(1).
        public mutating func next() -> Element? {
            node = links[node][0]
            return node >= 0 ? values[node] : nil
        }
    }

    /// An iterator over the elements in increasing order. Changing the set during the loop doesn't
    /// affect it. O(1).
    public func makeIterator() -> Iterator {
        Iterator(values: values, links: links, node: 0)
    }

    /// The number of elements. O(1).
    public var underestimatedCount: Int {
        count
    }
}

extension SkipList: ExpressibleByArrayLiteral {
    /// Creates a set from an array literal, with the default seed. Repeated elements are stored once.
    /// O(n log n) expected.
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension SkipList: CustomStringConvertible {
    /// The elements in increasing order, for example `SkipList([1, 2, 3])`. O(n).
    public var description: String {
        "SkipList(\(Array(self)))"
    }
}

extension SkipList: Equatable {
    /// Two sets are equal when they hold equal elements, whatever their seeds and node heights. O(n).
    public static func == (lhs: SkipList, rhs: SkipList) -> Bool {
        lhs.count == rhs.count && lhs.elementsEqual(rhs)
    }
}
