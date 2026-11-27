// Segment trees (M60 · A generic SegmentTree<T>, and Lazy propagation).
//
// `SegmentTree` is the iterative, bottom-up version: 2n slots, with the n values as leaves in
// storage[n..<2n] and every internal node i holding merge(storage[2i], storage[2i + 1]). A query walks
// up from both ends of the range at once, so it's O(log n) without recursion. It keeps a left and a
// right running result, so the merge doesn't have to be commutative: it only needs to be associative,
// with an identity element (a monoid).
//
// `LazySegmentTree` is the recursive, 4n version with pending tags, for adding to whole ranges.

/// A fixed-size array that answers "merge everything in this range" in O(log n), and still allows
/// O(log n) point updates.
///
/// You choose the merge, which must be **associative** (`merge(merge(a, b), c) == merge(a, merge(b, c))`),
/// and an **identity** element that changes nothing (`merge(identity, x) == x == merge(x, identity)`).
/// Sums use `+` and 0, minimums use `min` and the largest possible value, and maximums use `max` and the
/// smallest. The merge doesn't need to be commutative: elements are always merged left to right.
///
/// ```swift
/// var sums = SegmentTree([5, 3, 7, 9], identity: 0, merge: +)
/// sums.query(1..<3)           // 10, which is 3 + 7
/// sums.update(at: 2, to: 1)
/// sums.query(1...3)           // 13, which is 3 + 1 + 9
///
/// let lowest = SegmentTree.minimum([4, 2, 8])
/// lowest.query(...)           // 2
/// ```
///
/// Ranges are positions in the original array, and `query` accepts any range expression: `2..<5`,
/// `2...4`, `..<3`, `3...` or `...`. An empty range gives `identity`. `SegmentTree` is a value type,
/// and iterating over it visits the current values in order.
public struct SegmentTree<Element> {
    /// storage[count..<2 * count] are the values; storage[i] for 1 ≤ i < count merges its children
    /// 2i and 2i + 1. storage[0] is unused.
    private var storage: [Element]

    /// The number of values, n.
    public let count: Int

    /// Returns merge(identity, x) == x for every x.
    public let identity: Element

    /// Combines two neighbouring results; the left argument comes from the lower positions.
    private let merge: (Element, Element) -> Element

    /// Builds a tree over `values`. Each internal node is filled once, from the bottom up: O(n).
    public init(_ values: [Element], identity: Element, merge: @escaping (Element, Element) -> Element) {
        self.count = values.count
        self.identity = identity
        self.merge = merge
        self.storage = Array(repeating: identity, count: values.count) + values
        for node in stride(from: values.count - 1, through: 1, by: -1) {
            storage[node] = merge(storage[2 * node], storage[2 * node + 1])
        }
    }

    /// Builds a tree of `count` copies of `value`. O(n).
    public init(repeating value: Element, count: Int, identity: Element, merge: @escaping (Element, Element) -> Element) {
        self.init(Array(repeating: value, count: count), identity: identity, merge: merge)
    }

    /// True when the tree holds no values. O(1).
    public var isEmpty: Bool {
        count == 0
    }

    /// The current value at `index`, which must be in `0..<count`. O(1).
    public subscript(index: Int) -> Element {
        precondition(index >= 0 && index < count, "SegmentTree index \(index) out of range 0..<\(count)")
        return storage[count + index]
    }

    /// Merges the values in `range`, left to right, or returns `identity` if the range is empty.
    /// The range must lie within `0..<count`. O(log n).
    public func query<R: RangeExpression>(_ range: R) -> Element where R.Bound == Int {
        let bounds = range.relative(to: 0..<count)
        precondition(bounds.lowerBound >= 0 && bounds.upperBound <= count,
                     "SegmentTree range \(bounds) out of range 0..<\(count)")
        var left = bounds.lowerBound + count       // the next leaf (or node) to take from the left
        var right = bounds.upperBound + count      // one past the last one to take from the right
        var fromLeft = identity
        var fromRight = identity
        while left < right {
            if left & 1 == 1 {                     // a right child: its parent sticks out to the left
                fromLeft = merge(fromLeft, storage[left])
                left += 1
            }
            if right & 1 == 1 {                    // the node before `right` is a left child
                right -= 1
                fromRight = merge(storage[right], fromRight)
            }
            left /= 2
            right /= 2
        }
        return merge(fromLeft, fromRight)
    }

    /// Merges every value, as in `tree.query(...)`. O(log n).
    public func query(_ range: UnboundedRange) -> Element {
        query(0..<count)
    }

    /// Replaces the value at `index` with `value`, then recomputes the nodes on its path to the root.
    /// O(log n).
    public mutating func update(at index: Int, to value: Element) {
        precondition(index >= 0 && index < count, "SegmentTree index \(index) out of range 0..<\(count)")
        var node = count + index
        storage[node] = value
        while node > 1 {
            node /= 2
            storage[node] = merge(storage[2 * node], storage[2 * node + 1])
        }
    }

    /// Replaces the value at `index` with `transform(oldValue)`, for example adding to it. O(log n).
    public mutating func update(at index: Int, with transform: (Element) -> Element) {
        update(at: index, to: transform(self[index]))
    }

    /// The current values, in order. O(n).
    public var values: [Element] {
        Array(storage[count...])
    }
}

extension SegmentTree: Sequence {
    /// Iterates over the current values in order.
    public func makeIterator() -> IndexingIterator<ArraySlice<Element>> {
        storage[count...].makeIterator()
    }

    /// The number of values. O(1).
    public var underestimatedCount: Int {
        count
    }
}

extension SegmentTree: CustomStringConvertible {
    /// The current values, for example `SegmentTree([5, 3, 7])`. O(n).
    public var description: String {
        "SegmentTree(\(values))"
    }
}

extension SegmentTree where Element: AdditiveArithmetic {
    /// A tree of range sums: identity 0, merged with `+`. O(n).
    public static func sum(_ values: [Element]) -> SegmentTree {
        SegmentTree(values, identity: .zero, merge: +)
    }
}

extension SegmentTree where Element: FixedWidthInteger {
    /// A tree of range minimums: identity `Element.max`, merged with `min`. O(n).
    public static func minimum(_ values: [Element]) -> SegmentTree {
        SegmentTree(values, identity: .max, merge: { Swift.min($0, $1) })
    }

    /// A tree of range maximums: identity `Element.min`, merged with `max`. O(n).
    public static func maximum(_ values: [Element]) -> SegmentTree {
        SegmentTree(values, identity: .min, merge: { Swift.max($0, $1) })
    }
}

// MARK: - Lazy propagation

/// An array of integers that supports adding a value to every element of a range, and reading the
/// sum, minimum or maximum of a range, each in O(log n).
///
/// Every node stores the sum, minimum and maximum of its range, plus a **pending** addition that
/// still has to be passed down to its children. An update stops at nodes that lie wholly inside the
/// range and records the addition there; a later update that needs to go below such a node first
/// pushes the pending addition down one level. Reads don't push: they add up the pending additions
/// of the nodes above them on the way down instead, so they don't change the tree and aren't
/// `mutating`.
///
/// ```swift
/// var days = LazySegmentTree([4, 0, 2, 5])
/// days.add(3, to: 1...2)      // [4, 3, 5, 5]
/// days.sum(in: 0..<3)         // 12
/// days.minimum(in: 1...3)     // 3
/// ```
///
/// Like `SegmentTree`, ranges are any range expression within `0..<count`. Empty ranges are allowed:
/// adding to one does nothing, and its sum is 0. The minimum and maximum of an empty range are
/// `Int.max` and `Int.min`, the identities of `min` and `max`.
public struct LazySegmentTree {
    private var sums: [Int]
    private var minimums: [Int]
    private var maximums: [Int]
    /// Added to every element of the node's range, but not yet to its children's nodes.
    private var pending: [Int]

    /// The number of elements.
    public let count: Int

    /// Builds the tree over `values`, recursively from the root. O(n).
    public init(_ values: [Int]) {
        count = values.count
        let slots = Swift.max(1, 4 * values.count)
        sums = Array(repeating: 0, count: slots)
        minimums = Array(repeating: Int.max, count: slots)
        maximums = Array(repeating: Int.min, count: slots)
        pending = Array(repeating: 0, count: slots)
        if !values.isEmpty {
            build(values, node: 1, low: 0, high: values.count - 1)
        }
    }

    /// Builds a tree of `count` zeros. O(n).
    public init(count: Int) {
        self.init(Array(repeating: 0, count: count))
    }

    /// True when the tree holds no elements. O(1).
    public var isEmpty: Bool {
        count == 0
    }

    /// Adds `delta` to every element in `range`. O(log n).
    public mutating func add<R: RangeExpression>(_ delta: Int, to range: R) where R.Bound == Int {
        let bounds = checked(range)
        guard !bounds.isEmpty else { return }
        add(delta, bounds.lowerBound, bounds.upperBound - 1, node: 1, low: 0, high: count - 1)
    }

    /// The sum of the elements in `range`, or 0 if it's empty. O(log n).
    public func sum<R: RangeExpression>(in range: R) -> Int where R.Bound == Int {
        let bounds = checked(range)
        guard !bounds.isEmpty else { return 0 }
        return query(bounds.lowerBound, bounds.upperBound - 1, carry: 0, node: 1, low: 0, high: count - 1).sum
    }

    /// The smallest element in `range`, or `Int.max` if it's empty. O(log n).
    public func minimum<R: RangeExpression>(in range: R) -> Int where R.Bound == Int {
        let bounds = checked(range)
        guard !bounds.isEmpty else { return Int.max }
        return query(bounds.lowerBound, bounds.upperBound - 1, carry: 0, node: 1, low: 0, high: count - 1).minimum
    }

    /// The largest element in `range`, or `Int.min` if it's empty. O(log n).
    public func maximum<R: RangeExpression>(in range: R) -> Int where R.Bound == Int {
        let bounds = checked(range)
        guard !bounds.isEmpty else { return Int.min }
        return query(bounds.lowerBound, bounds.upperBound - 1, carry: 0, node: 1, low: 0, high: count - 1).maximum
    }

    /// Adds `delta` to every element, as in `tree.add(1, to: ...)`. O(1) at the root.
    public mutating func add(_ delta: Int, to range: UnboundedRange) {
        add(delta, to: 0..<count)
    }

    /// The sum of every element, as in `tree.sum(in: ...)`. O(1).
    public func sum(in range: UnboundedRange) -> Int {
        sum(in: 0..<count)
    }

    /// The smallest element, or `Int.max` if the tree is empty. O(1).
    public func minimum(in range: UnboundedRange) -> Int {
        minimum(in: 0..<count)
    }

    /// The largest element, or `Int.min` if the tree is empty. O(1).
    public func maximum(in range: UnboundedRange) -> Int {
        maximum(in: 0..<count)
    }

    /// The element at `index`, which must be in `0..<count`. O(log n).
    public func value(at index: Int) -> Int {
        precondition(index >= 0 && index < count, "LazySegmentTree index \(index) out of range 0..<\(count)")
        return sum(in: index...index)
    }

    /// Every element, in order. O(n).
    public var values: [Int] {
        var result: [Int] = []
        result.reserveCapacity(count)
        if count > 0 {
            collect(into: &result, carry: 0, node: 1, low: 0, high: count - 1)
        }
        return result
    }

    // MARK: - Recursion

    private func checked<R: RangeExpression>(_ range: R) -> Range<Int> where R.Bound == Int {
        let bounds = range.relative(to: 0..<count)
        precondition(bounds.lowerBound >= 0 && bounds.upperBound <= count,
                     "LazySegmentTree range \(bounds) out of range 0..<\(count)")
        return bounds
    }

    private mutating func build(_ values: [Int], node: Int, low: Int, high: Int) {
        if low == high {
            sums[node] = values[low]
            minimums[node] = values[low]
            maximums[node] = values[low]
            return
        }
        let mid = (low + high) / 2
        build(values, node: 2 * node, low: low, high: mid)
        build(values, node: 2 * node + 1, low: mid + 1, high: high)
        pull(node)
    }

    /// Recomputes a node from its two children.
    private mutating func pull(_ node: Int) {
        sums[node] = sums[2 * node] + sums[2 * node + 1]
        minimums[node] = Swift.min(minimums[2 * node], minimums[2 * node + 1])
        maximums[node] = Swift.max(maximums[2 * node], maximums[2 * node + 1])
    }

    /// Adds `delta` to every element of a node's range, `length` elements, and remembers it for the
    /// children. Additions compose by adding, so the new tag is added to any older one.
    private mutating func apply(_ delta: Int, to node: Int, length: Int) {
        sums[node] += delta * length
        minimums[node] += delta
        maximums[node] += delta
        pending[node] += delta
    }

    /// Hands a node's pending addition to its two children.
    private mutating func push(_ node: Int, low: Int, mid: Int, high: Int) {
        guard pending[node] != 0 else { return }
        apply(pending[node], to: 2 * node, length: mid - low + 1)
        apply(pending[node], to: 2 * node + 1, length: high - mid)
        pending[node] = 0
    }

    private mutating func add(_ delta: Int, _ left: Int, _ right: Int, node: Int, low: Int, high: Int) {
        if right < low || high < left { return }
        if left <= low && high <= right {
            apply(delta, to: node, length: high - low + 1)
            return
        }
        let mid = (low + high) / 2
        push(node, low: low, mid: mid, high: high)
        add(delta, left, right, node: 2 * node, low: low, high: mid)
        add(delta, left, right, node: 2 * node + 1, low: mid + 1, high: high)
        pull(node)
    }

    /// `carry` is the total pending addition of the nodes above `node`, which hasn't reached it yet.
    private func query(_ left: Int, _ right: Int, carry: Int, node: Int, low: Int, high: Int) -> (sum: Int, minimum: Int, maximum: Int) {
        if right < low || high < left { return (0, Int.max, Int.min) }
        if left <= low && high <= right {
            return (sums[node] + carry * (high - low + 1), minimums[node] + carry, maximums[node] + carry)
        }
        let mid = (low + high) / 2
        let below = carry + pending[node]
        let a = query(left, right, carry: below, node: 2 * node, low: low, high: mid)
        let b = query(left, right, carry: below, node: 2 * node + 1, low: mid + 1, high: high)
        return (a.sum + b.sum, Swift.min(a.minimum, b.minimum), Swift.max(a.maximum, b.maximum))
    }

    private func collect(into result: inout [Int], carry: Int, node: Int, low: Int, high: Int) {
        if low == high {
            result.append(sums[node] + carry)
            return
        }
        let mid = (low + high) / 2
        let below = carry + pending[node]
        collect(into: &result, carry: below, node: 2 * node, low: low, high: mid)
        collect(into: &result, carry: below, node: 2 * node + 1, low: mid + 1, high: high)
    }
}

extension LazySegmentTree: CustomStringConvertible {
    /// The current elements, for example `LazySegmentTree([4, 3, 5, 5])`. O(n).
    public var description: String {
        "LazySegmentTree(\(values))"
    }
}
