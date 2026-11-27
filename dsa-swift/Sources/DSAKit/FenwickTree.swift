// A Fenwick tree, or binary indexed tree (M61 · Fenwick trees).
//
// Inside, the tree is 1-indexed: slot i (1 ≤ i ≤ n) holds the sum of the lowbit(i) values ending at
// position i, where lowbit(i) = i & -i is i's lowest set bit. A prefix sum adds up slots while
// stripping the lowest set bit (i -= i & -i); an update climbs to every slot whose range covers the
// position (i += i & -i). Both visit at most log₂ n + 1 slots.
//
// The public API is 0-indexed, like every Swift array: position p lives in slot p + 1.

/// An array of integers that answers prefix sums and range sums in O(log n), and allows O(log n)
/// additions to single elements.
///
/// ```swift
/// var counts = FenwickTree([3, 2, -1, 6, 5])
/// counts.prefixSum(through: 2)    // 4, which is 3 + 2 + -1
/// counts.add(10, at: 1)           // [3, 12, -1, 6, 5]
/// counts.sum(in: 1...3)           // 17
/// counts[1]                       // 12
/// ```
///
/// When every element is non-negative, `lowerBound(prefix:)` finds the first position where the
/// running total reaches a target, in O(log n). With counts of values as the elements, that finds
/// the kth smallest value of a changing multiset.
public struct FenwickTree {
    /// Slot 0 is unused; slot i covers positions i - lowbit(i) + 1 ... i, counted from 1.
    private var tree: [Int]

    /// The number of elements, n.
    public var count: Int {
        tree.count - 1
    }

    /// True when the tree holds no elements. O(1).
    public var isEmpty: Bool {
        count == 0
    }

    /// Creates a tree of `count` zeros. O(n).
    public init(count: Int) {
        precondition(count >= 0, "FenwickTree count must not be negative")
        tree = Array(repeating: 0, count: count + 1)
    }

    /// Creates a tree holding `values`. Each slot passes its total up to the one slot directly above
    /// it, so the build is O(n), not n separate O(log n) additions.
    public init(_ values: [Int]) {
        tree = [0] + values
        for slot in 1..<tree.count {
            let parent = slot + (slot & -slot)
            if parent < tree.count {
                tree[parent] += tree[slot]
            }
        }
    }

    /// Adds `delta` to the element at `index`, which must be in `0..<count`. O(log n).
    public mutating func add(_ delta: Int, at index: Int) {
        precondition(index >= 0 && index < count, "FenwickTree index \(index) out of range 0..<\(count)")
        var slot = index + 1
        while slot < tree.count {
            tree[slot] += delta
            slot += slot & -slot                 // the next slot whose range covers this position
        }
    }

    /// The sum of the first `length` elements, positions `0..<length`. `length` must be in
    /// `0...count`; a length of 0 gives 0. O(log n).
    public func prefixSum(upTo length: Int) -> Int {
        precondition(length >= 0 && length <= count, "FenwickTree prefix length \(length) out of range 0...\(count)")
        var slot = length
        var total = 0
        while slot > 0 {
            total += tree[slot]
            slot -= slot & -slot                 // drop the lowest set bit: the range just before
        }
        return total
    }

    /// The sum of the elements at positions `0...index`. `index` must be in `0..<count`. O(log n).
    public func prefixSum(through index: Int) -> Int {
        precondition(index >= 0 && index < count, "FenwickTree index \(index) out of range 0..<\(count)")
        return prefixSum(upTo: index + 1)
    }

    /// The sum of the elements in `range`, which can be any range expression within `0..<count`,
    /// such as `2..<5`, `2...4` or `..<3`. An empty range gives 0. O(log n).
    public func sum<R: RangeExpression>(in range: R) -> Int where R.Bound == Int {
        let bounds = range.relative(to: 0..<count)
        precondition(bounds.lowerBound >= 0 && bounds.upperBound <= count,
                     "FenwickTree range \(bounds) out of range 0..<\(count)")
        return prefixSum(upTo: bounds.upperBound) - prefixSum(upTo: bounds.lowerBound)
    }

    /// The sum of every element, as in `tree.sum(in: ...)`. O(log n).
    public func sum(in range: UnboundedRange) -> Int {
        prefixSum(upTo: count)
    }

    /// The element at `index`, which must be in `0..<count`. O(log n).
    public subscript(index: Int) -> Int {
        sum(in: index...index)
    }

    /// Sets the element at `index` to `value`, by adding the difference. O(log n).
    public mutating func set(_ value: Int, at index: Int) {
        add(value - self[index], at: index)
    }

    /// The smallest position whose prefix sum, `prefixSum(through:)`, is at least `target`, or `count`
    /// if no position reaches it. A `target` of 0 or less gives 0.
    ///
    /// Every element must be non-negative, so the prefix sums never decrease. The search climbs
    /// down powers of two (binary lifting), so it's O(log n) rather than a binary search over
    /// `prefixSum` calls, which would be O(log² n).
    ///
    /// If element v counts how many times the value v is in a multiset, `lowerBound(prefix: k)` is the
    /// kth smallest value, counting from 1.
    public func lowerBound(prefix target: Int) -> Int {
        guard target > 0 else { return 0 }
        var position = 0                         // the largest slot known to have a total below target
        var remaining = target
        var step = 1
        while step * 2 <= count {
            step *= 2
        }
        while step > 0 {
            let next = position + step
            if next <= count && tree[next] < remaining {
                position = next                  // everything up to `next` still falls short
                remaining -= tree[next]
            }
            step /= 2
        }
        return position                          // slot position + 1 reaches it: position `position`, 0-indexed
    }

    /// The current elements, in order, recovered by undoing the build. O(n).
    public var values: [Int] {
        var slots = tree
        for slot in stride(from: slots.count - 1, through: 1, by: -1) {
            let parent = slot + (slot & -slot)
            if parent < slots.count {
                slots[parent] -= slots[slot]
            }
        }
        return Array(slots.dropFirst())
    }
}

extension FenwickTree: ExpressibleByArrayLiteral {
    /// Creates a tree from an array literal, such as `[3, 2, -1]`. O(n).
    public init(arrayLiteral elements: Int...) {
        self.init(elements)
    }
}

extension FenwickTree: CustomStringConvertible {
    /// The current elements, for example `FenwickTree([3, 2, -1])`. O(n).
    public var description: String {
        "FenwickTree(\(values))"
    }
}
