// Union-find, also called a disjoint-set union or DSU (M45 · Path compression and union by rank).
//
// The elements are the integers 0..<count, and every element belongs to exactly one set. Each set is
// a tree stored in a parent array: `parent[x]` is x's parent, and the root, whose parent is itself,
// represents the whole set. `find` walks up to the root; `union` hangs one root under the other.
//
// Two optimisations together make every operation almost O(1):
// - Union by size: the smaller tree always goes under the larger root, so no tree is deeper than
//   log₂ n.
// - Path compression: after finding a root, `find` points every node it walked past straight at
//   that root, so the next walk from any of them takes one step.
// With both, any sequence of m operations on n elements costs O(m α(n)), where α is the inverse
// Ackermann function, which is at most 4 for any n that fits in memory.
//
// Design choice: `find` is `mutating`. Path compression rewrites the parent array, so even a
// question like "are these two connected?" changes the structure (never the answer). The
// alternative, hiding the array in a class so `find` can be non-mutating, would give up value
// semantics: copying a UnionFind would share its storage. Instead, `UnionFind` is a plain struct,
// a copy is independent, and you hold it in a `var`. The cost is that `connected(_:_:)` and
// `size(ofSetContaining:)` are mutating too, and can't be called on a `let`.

/// Disjoint sets over the integers `0..<count`, with near-constant-time `union` and `find`.
///
/// ```swift
/// var sets = UnionFind(count: 5)      // {0} {1} {2} {3} {4}
/// sets.union(0, 1)                    // true: {0, 1} {2} {3} {4}
/// sets.union(3, 4)                    // true: {0, 1} {2} {3, 4}
/// sets.union(1, 0)                    // false: already in one set
/// sets.connected(0, 4)                // false
/// sets.componentCount                 // 3
/// sets.size(ofSetContaining: 4)       // 2
/// ```
///
/// Every element passed in must be in `0..<count`; anything else traps, like an array index. To use
/// other keys, such as strings, give each one an index with a dictionary first.
///
/// `find` uses path compression, so it's `mutating`, and so are `connected(_:_:)` and
/// `size(ofSetContaining:)`. Hold a `UnionFind` in a `var`.
public struct UnionFind {
    /// `parent[x]` is x's parent in its set's tree. A root is its own parent.
    private var parent: [Int]

    /// `sizes[root]` is the number of elements in that root's set. Only roots' entries are kept
    /// up to date.
    private var sizes: [Int]

    /// The number of separate sets. It starts at `count` and drops by one with every union that
    /// joins two different sets. O(1).
    public private(set) var componentCount: Int

    /// Creates `count` elements, `0..<count`, each in a set of its own. O(n).
    public init(count: Int) {
        precondition(count >= 0, "UnionFind needs a count of zero or more")
        parent = Array(0..<count)
        sizes = Array(repeating: 1, count: count)
        componentCount = count
    }

    /// The number of elements, `n`. O(1).
    public var count: Int {
        parent.count
    }

    /// The root that represents `element`'s set. Two elements are in the same set exactly when
    /// they have the same root.
    ///
    /// It walks up to the root, then walks the same path again pointing every node straight at the
    /// root (path compression). Both walks are loops, not recursion, so even a very deep tree can't
    /// overflow the stack. Amortised O(α(n)); a single call is at most O(log n).
    public mutating func find(_ element: Int) -> Int {
        var root = element
        while parent[root] != root {
            root = parent[root]
        }
        var node = element
        while node != root {
            let next = parent[node]
            parent[node] = root
            node = next
        }
        return root
    }

    /// Joins the sets containing `first` and `second`. Returns true if they were in different sets,
    /// and false if they were already joined, in which case nothing changes. A false result is how
    /// you detect that an edge would close a cycle.
    ///
    /// The smaller set's root goes under the larger set's root (union by size). Amortised O(α(n)).
    @discardableResult
    public mutating func union(_ first: Int, _ second: Int) -> Bool {
        var rootA = find(first)
        var rootB = find(second)
        if rootA == rootB { return false }
        if sizes[rootA] < sizes[rootB] {
            swap(&rootA, &rootB)
        }
        parent[rootB] = rootA
        sizes[rootA] += sizes[rootB]
        componentCount -= 1
        return true
    }

    /// True when `first` and `second` are in the same set. Mutating, because the two finds compress
    /// paths. Amortised O(α(n)).
    public mutating func connected(_ first: Int, _ second: Int) -> Bool {
        find(first) == find(second)
    }

    /// The number of elements in the set containing `element`, including itself. Amortised O(α(n)).
    public mutating func size(ofSetContaining element: Int) -> Int {
        sizes[find(element)]
    }

    /// Adds a new element in a set of its own and returns it. It's the next integer, `count` before
    /// the call. Useful when the elements arrive over time. Amortised O(1).
    @discardableResult
    public mutating func addElement() -> Int {
        let element = parent.count
        parent.append(element)
        sizes.append(1)
        componentCount += 1
        return element
    }

    /// Every set, as its elements in increasing order, with the sets ordered by their smallest
    /// element. The order is fixed, so the result is safe to print or compare. O(n α(n)).
    public mutating func groups() -> [[Int]] {
        var groupOfRoot: [Int: Int] = [:]
        var result: [[Int]] = []
        for element in 0..<parent.count {
            let root = find(element)
            if let index = groupOfRoot[root] {
                result[index].append(element)
            } else {
                groupOfRoot[root] = result.count
                result.append([element])
            }
        }
        return result
    }

    /// The root of `element` without compressing anything, for the non-mutating description. O(log n)
    /// thanks to union by size.
    private func rootWithoutCompressing(_ element: Int) -> Int {
        var root = element
        while parent[root] != root {
            root = parent[root]
        }
        return root
    }
}

extension UnionFind: CustomStringConvertible {
    /// The sets in the same order as `groups()`, for example `UnionFind([[0, 1, 4], [2], [3]])`.
    /// O(n log n).
    public var description: String {
        var groupOfRoot: [Int: Int] = [:]
        var result: [[Int]] = []
        for element in 0..<parent.count {
            let root = rootWithoutCompressing(element)
            if let index = groupOfRoot[root] {
                result[index].append(element)
            } else {
                groupOfRoot[root] = result.count
                result.append([element])
            }
        }
        return "UnionFind(\(result))"
    }
}
