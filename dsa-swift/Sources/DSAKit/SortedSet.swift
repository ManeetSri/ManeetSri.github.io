// An ordered set and an ordered map (M38 · Build an ordered set and map in Swift).
//
// Swift's Set and Dictionary are hash tables: O(1) lookups on average, but no order, so "the largest
// key at or below x" means scanning every key. A sorted array answers that with binary search, but
// inserting or removing shifts up to n elements. These two types keep their keys in the balanced AVL
// core from AVLTree.swift, so every operation, including floor, ceiling and range queries, is
// O(log n). It's the role Java's TreeSet and TreeMap and C++'s std::set and std::map play.
//
// Both are value types with copy-on-write (the core handles it), and both iterate in increasing key
// order.

// MARK: - SortedSet

/// A set that keeps its elements sorted: O(log n) insert, remove and contains, O(log n) floor, ceiling,
/// predecessor and successor, and range queries in O(log n + k) for k results.
///
/// ```swift
/// var slots: SortedSet = [900, 1300, 1030]
/// slots.insert(1100)
/// slots.floor(1200)                       // Optional(1100): the latest slot at or before 1200
/// slots.ceiling(1200)                     // Optional(1300)
/// slots.elements(in: 1000...1200)         // [1030, 1100]
/// print(Array(slots))                     // [900, 1030, 1100, 1300]
/// ```
public struct SortedSet<Element: Comparable> {
    var core = AVLCore<Element, Void>()

    /// Creates an empty set. O(1).
    public init() {}

    /// Creates a set holding the distinct elements of `elements`. O(n log n).
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            insert(element)
        }
    }

    /// The number of elements. O(1).
    public var count: Int {
        core.count
    }

    /// True when the set is empty. O(1).
    public var isEmpty: Bool {
        core.count == 0
    }

    /// Inserts `element` if it isn't there. Returns true if it was inserted, false if an equal element
    /// was already present. O(log n).
    @discardableResult
    public mutating func insert(_ element: Element) -> Bool {
        core.insertIfAbsent(element, ())
    }

    /// Removes `element`, returning the stored element equal to it, or nil if there wasn't one.
    /// O(log n).
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        core.remove(element)?.key
    }

    /// Removes every element. O(n) to release the nodes.
    public mutating func removeAll() {
        core.removeAll()
    }

    /// True if the set contains an element equal to `element`. O(log n).
    public func contains(_ element: Element) -> Bool {
        core.node(for: element) != nil
    }

    /// The smallest element, or nil when empty. O(log n).
    public var first: Element? {
        core.firstNode?.key
    }

    /// The largest element, or nil when empty. O(log n).
    public var last: Element? {
        core.lastNode?.key
    }

    /// Removes and returns the smallest element, or nil when empty. O(log n).
    @discardableResult
    public mutating func popFirst() -> Element? {
        guard let smallest = first else { return nil }
        return remove(smallest)
    }

    /// Removes and returns the largest element, or nil when empty. O(log n).
    @discardableResult
    public mutating func popLast() -> Element? {
        guard let largest = last else { return nil }
        return remove(largest)
    }

    /// The largest element ≤ `element`, or nil if there's none. O(log n).
    public func floor(_ element: Element) -> Element? {
        core.floorNode(element, inclusive: true)?.key
    }

    /// The smallest element ≥ `element`, or nil if there's none. O(log n).
    public func ceiling(_ element: Element) -> Element? {
        core.ceilingNode(element, inclusive: true)?.key
    }

    /// The largest element strictly less than `element`, or nil if there's none. `element` needn't be
    /// in the set. O(log n).
    public func predecessor(of element: Element) -> Element? {
        core.floorNode(element, inclusive: false)?.key
    }

    /// The smallest element strictly greater than `element`, or nil if there's none. `element` needn't
    /// be in the set. O(log n).
    public func successor(of element: Element) -> Element? {
        core.ceilingNode(element, inclusive: false)?.key
    }

    /// The elements in `range`, in increasing order. O(log n + k) for k results.
    public func elements(in range: ClosedRange<Element>) -> [Element] {
        core.entries(from: range.lowerBound, to: range.upperBound, includingUpper: true).map { $0.key }
    }

    /// The elements in the half-open `range`, in increasing order. O(log n + k) for k results.
    public func elements(in range: Range<Element>) -> [Element] {
        core.entries(from: range.lowerBound, to: range.upperBound, includingUpper: false).map { $0.key }
    }

    /// True when the balanced core's invariants hold. Used by the tests. O(n).
    var isBalanced: Bool {
        core.checkInvariants()
    }
}

extension SortedSet: Sequence {
    /// Visits the elements in increasing order.
    public struct Iterator: IteratorProtocol {
        var base: AVLCore<Element, Void>.Iterator

        /// The next element in increasing order, or nil at the end. Amortised O(1).
        public mutating func next() -> Element? {
            base.next()?.key
        }
    }

    /// An iterator over the elements in increasing order. Changing the set during the loop doesn't
    /// affect it. O(log n).
    public func makeIterator() -> Iterator {
        Iterator(base: core.makeIterator())
    }

    /// The number of elements. O(1).
    public var underestimatedCount: Int {
        core.count
    }
}

extension SortedSet: ExpressibleByArrayLiteral {
    /// Creates a set from an array literal. Repeated elements are stored once. O(n log n).
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension SortedSet: CustomStringConvertible {
    /// The elements in increasing order, for example `SortedSet([1, 2, 3])`. O(n).
    public var description: String {
        "SortedSet(\(Array(self)))"
    }
}

extension SortedSet: Equatable {
    /// Two sets are equal when they hold equal elements. O(n).
    public static func == (lhs: SortedSet, rhs: SortedSet) -> Bool {
        lhs.count == rhs.count && lhs.elementsEqual(rhs)
    }
}

// MARK: - SortedMap

/// A dictionary that keeps its keys sorted: O(log n) lookup, insert, update and remove, O(log n)
/// floor, ceiling, predecessor and successor, and range queries in O(log n + k) for k results.
///
/// ```swift
/// var prices: SortedMap = [10: 101, 20: 99]      // timestamp → price
/// prices[30] = 104
/// prices[20] = 98                                // overwrites
/// prices.floor(25)?.value                        // Optional(98): the price in force at time 25
/// prices.elements(in: 15...30).map { $0.key }    // [20, 30]
/// ```
///
/// Like `Dictionary`, it's a sequence of `(key: Key, value: Value)` pairs, but in increasing key order.
public struct SortedMap<Key: Comparable, Value> {
    /// One entry: a key and its value.
    public typealias Element = (key: Key, value: Value)

    var core = AVLCore<Key, Value>()

    /// Creates an empty map. O(1).
    public init() {}

    /// Creates a map from key-value pairs. A key that appears more than once keeps its last value.
    /// O(n log n).
    public init<S: Sequence>(_ pairs: S) where S.Element == (Key, Value) {
        for (key, value) in pairs {
            self[key] = value
        }
    }

    /// The number of entries. O(1).
    public var count: Int {
        core.count
    }

    /// True when the map has no entries. O(1).
    public var isEmpty: Bool {
        core.count == 0
    }

    /// The value for `key`, or nil if it isn't there. Setting a value inserts or overwrites; setting
    /// nil removes the key. O(log n).
    public subscript(key: Key) -> Value? {
        get {
            core.node(for: key)?.value
        }
        set {
            if let newValue {
                core.updateValue(newValue, forKey: key)
            } else {
                core.remove(key)
            }
        }
    }

    /// The value for `key`, or `defaultValue` if it isn't there, so counting reads
    /// `counts[x, default: 0] += 1`. Setting always stores the value. O(log n).
    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            core.node(for: key)?.value ?? defaultValue()
        }
        set {
            core.updateValue(newValue, forKey: key)
        }
    }

    /// Stores `value` for `key` and returns the value it replaced, or nil if the key is new. O(log n).
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        core.updateValue(value, forKey: key)
    }

    /// Removes `key` and returns its value, or nil if it wasn't there. O(log n).
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        core.remove(key)?.value
    }

    /// Removes every entry. O(n) to release the nodes.
    public mutating func removeAll() {
        core.removeAll()
    }

    /// The keys in increasing order. O(n).
    public var keys: [Key] {
        map { $0.key }
    }

    /// The values, in increasing order of their keys. O(n).
    public var values: [Value] {
        map { $0.value }
    }

    /// The entry with the smallest key, or nil when empty. O(log n).
    public var first: Element? {
        core.firstNode.map { ($0.key, $0.value) }
    }

    /// The entry with the largest key, or nil when empty. O(log n).
    public var last: Element? {
        core.lastNode.map { ($0.key, $0.value) }
    }

    /// Removes and returns the entry with the smallest key, or nil when empty. O(log n).
    @discardableResult
    public mutating func popFirst() -> Element? {
        guard let smallest = core.firstNode?.key else { return nil }
        return core.remove(smallest)
    }

    /// Removes and returns the entry with the largest key, or nil when empty. O(log n).
    @discardableResult
    public mutating func popLast() -> Element? {
        guard let largest = core.lastNode?.key else { return nil }
        return core.remove(largest)
    }

    /// The entry with the largest key ≤ `key`, or nil if there's none. O(log n).
    public func floor(_ key: Key) -> Element? {
        core.floorNode(key, inclusive: true).map { ($0.key, $0.value) }
    }

    /// The entry with the smallest key ≥ `key`, or nil if there's none. O(log n).
    public func ceiling(_ key: Key) -> Element? {
        core.ceilingNode(key, inclusive: true).map { ($0.key, $0.value) }
    }

    /// The entry with the largest key strictly less than `key`, or nil if there's none. O(log n).
    public func predecessor(of key: Key) -> Element? {
        core.floorNode(key, inclusive: false).map { ($0.key, $0.value) }
    }

    /// The entry with the smallest key strictly greater than `key`, or nil if there's none. O(log n).
    public func successor(of key: Key) -> Element? {
        core.ceilingNode(key, inclusive: false).map { ($0.key, $0.value) }
    }

    /// The entries whose keys are in `range`, in increasing key order. O(log n + k) for k results.
    public func elements(in range: ClosedRange<Key>) -> [Element] {
        core.entries(from: range.lowerBound, to: range.upperBound, includingUpper: true)
    }

    /// The entries whose keys are in the half-open `range`, in increasing key order. O(log n + k).
    public func elements(in range: Range<Key>) -> [Element] {
        core.entries(from: range.lowerBound, to: range.upperBound, includingUpper: false)
    }

    /// True when the balanced core's invariants hold. Used by the tests. O(n).
    var isBalanced: Bool {
        core.checkInvariants()
    }
}

extension SortedMap: Sequence {
    /// Visits the entries in increasing key order.
    public struct Iterator: IteratorProtocol {
        var base: AVLCore<Key, Value>.Iterator

        /// The next entry in increasing key order, or nil at the end. Amortised O(1).
        public mutating func next() -> Element? {
            base.next()
        }
    }

    /// An iterator over the entries in increasing key order. Changing the map during the loop doesn't
    /// affect it. O(log n).
    public func makeIterator() -> Iterator {
        Iterator(base: core.makeIterator())
    }

    /// The number of entries. O(1).
    public var underestimatedCount: Int {
        core.count
    }
}

extension SortedMap: ExpressibleByDictionaryLiteral {
    /// Creates a map from a dictionary literal such as `[3: "c", 1: "a"]`. A repeated key keeps its
    /// last value. O(n log n).
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements)
    }
}

extension SortedMap: CustomStringConvertible {
    /// The entries in key order, for example `SortedMap([1: "a", 2: "b"])`. O(n).
    public var description: String {
        let entries = map { "\(String(reflecting: $0.key)): \(String(reflecting: $0.value))" }
        return "SortedMap([\(entries.joined(separator: ", "))])"
    }
}

extension SortedMap: Equatable where Value: Equatable {
    /// Two maps are equal when they hold the same keys with equal values. O(n).
    public static func == (lhs: SortedMap, rhs: SortedMap) -> Bool {
        lhs.count == rhs.count && lhs.elementsEqual(rhs) { $0.key == $1.key && $0.value == $1.value }
    }
}
