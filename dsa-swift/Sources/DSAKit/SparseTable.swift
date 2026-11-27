// A sparse table for O(1) range queries on an array that never changes (M62 · Sparse tables and
// O(1) RMQ).
//
// Level 0 is the array itself. Level j holds, for every start index i, the combined value of the
// 2^j elements beginning at i: `levels[j][i] = combine(levels[j - 1][i], levels[j - 1][i + 2^(j - 1)])`.
// There are ⌊log₂ n⌋ + 1 levels of at most n entries each, so building takes O(n log n) time and
// memory.
//
// A query for `l...r` covers the range with two blocks of the same power-of-two length k, the
// largest that fits: one starting at l and one ending at r. They overlap in the middle, so some
// elements are counted twice. That's harmless for an **idempotent** operation, one where combining
// a value with itself changes nothing: min(x, x) = x, max(x, x) = x, gcd(x, x) = x, x & x = x,
// x | x = x. It's wrong for sums, products, counts and XOR: elements in the overlap would be added
// twice. For range sums, use prefix sums (no updates) or a Fenwick or segment tree (with updates).

/// An immutable array that answers range queries for an idempotent operation (min, max, gcd, bitwise
/// and/or) in O(1), after an O(n log n) build.
///
/// ```swift
/// let temperatures = [14, 9, 17, 5, 12, 20, 8]
/// let coldest = SparseTable(temperatures, combine: min)
/// coldest.query(1...4)                   // 5
/// coldest.query(5...6)                   // 8
///
/// let warmest = SparseTable.maximum(temperatures)
/// warmest.query(0...2)                   // 17
///
/// func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }
/// let shared = SparseTable([12, 18, 30, 45], combine: gcd)
/// shared.query(0...2)                    // 6
/// ```
///
/// **The combine closure must be idempotent** (`combine(x, x) == x`) as well as associative. A query
/// combines two overlapping blocks, so with `+` the elements in the overlap would be counted twice
/// and the answers would be wrong. Sparse tables can't do range sums in O(1); prefix sums can.
///
/// The table is fixed once built: there's no update. Changing one element would change O(n) entries.
/// It's a `RandomAccessCollection` of the original elements, so `count`, indexing and `for`-`in` all
/// work as they do on the array it came from.
public struct SparseTable<Element> {
    /// `levels[j][i]` combines the 2^j elements starting at index i. `levels[0]` is the input.
    private let levels: [[Element]]

    /// An associative, idempotent operation such as `min`, `max` or gcd.
    private let combine: (Element, Element) -> Element

    /// Builds the table for `elements`. `combine` must be associative and idempotent: `min`, `max`,
    /// gcd, `&` or `|`, but never `+`. O(n log n) time and memory.
    public init(_ elements: [Element], combine: @escaping (Element, Element) -> Element) {
        self.combine = combine
        var levels = [elements]
        var width = 1                            // 2^(j - 1): half the block length of the level being built
        while 2 * width <= elements.count {
            let previous = levels[levels.count - 1]
            let level = (0...(elements.count - 2 * width)).map { start in
                combine(previous[start], previous[start + width])
            }
            levels.append(level)
            width *= 2
        }
        self.levels = levels
    }

    /// The combined value of the elements in `range`: for example their minimum. The range must be
    /// non-empty and inside `0..<count`, or this traps, like an array index. O(1).
    public func query(_ range: ClosedRange<Int>) -> Element {
        precondition(range.lowerBound >= 0 && range.upperBound < count, "SparseTable range \(range) is out of bounds for \(count) elements")
        let level = Self.floorLog2(range.count)
        let length = 1 << level                  // the largest power of two that fits in the range
        // Two blocks of `length`: one starting at the left end, one ending at the right end. They
        // overlap unless the range's length is a power of two, which idempotence makes harmless.
        return combine(levels[level][range.lowerBound], levels[level][range.upperBound - length + 1])
    }

    /// The combined value of the elements in a half-open `range`, which must be non-empty and inside
    /// `0..<count`. O(1).
    public func query(_ range: Range<Int>) -> Element {
        precondition(!range.isEmpty, "SparseTable can't query an empty range")
        return query(range.lowerBound...(range.upperBound - 1))
    }

    /// The number of levels the table stores, ⌊log₂ n⌋ + 1 (or 1 for an empty table). O(1).
    public var levelCount: Int {
        levels.count
    }

    /// ⌊log₂ value⌋ for a positive value: the index of its highest set bit. O(1).
    private static func floorLog2(_ value: Int) -> Int {
        Int.bitWidth - 1 - value.leadingZeroBitCount
    }
}

extension SparseTable: RandomAccessCollection {
    /// Always 0. O(1).
    public var startIndex: Int { 0 }

    /// The number of elements the table was built from. O(1).
    public var endIndex: Int { levels[0].count }

    /// The original element at `position`. O(1).
    public subscript(position: Int) -> Element {
        levels[0][position]
    }
}

extension SparseTable where Element: Comparable {
    /// A table whose queries return the smallest element in a range. O(n log n).
    public static func minimum(_ elements: [Element]) -> SparseTable {
        SparseTable(elements, combine: { Swift.min($0, $1) })
    }

    /// A table whose queries return the largest element in a range. O(n log n).
    public static func maximum(_ elements: [Element]) -> SparseTable {
        SparseTable(elements, combine: { Swift.max($0, $1) })
    }
}

extension SparseTable: CustomStringConvertible {
    /// The original elements, for example `SparseTable([3, 1, 2])`. O(n).
    public var description: String {
        "SparseTable(\(levels[0]))"
    }
}
