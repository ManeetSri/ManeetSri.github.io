// A self-balancing binary search tree (M38 · AVL trees: insert and delete), plus the balanced core
// that SortedSet and SortedMap are built on (M38 · Build an ordered set and map in Swift).
//
// Every node stores its height: 1 for a leaf, and 1 + the taller child's height above that. A node's
// balance factor is height(left) - height(right), and an AVL tree keeps every balance factor at -1, 0
// or 1. After an insert or a removal, each node on the way back up recomputes its height and, if its
// balance factor has reached 2 or -2, fixes itself with one rotation (left-left, right-right) or two
// (left-right, right-left). That keeps the height below about 1.44 log2(n + 2), so every operation is
// O(log n).
//
// Why recursion is fine here: insert and remove recurse once per level, and the tree has at most
// about 1.44 log2(n + 2) levels: at most 23 for a hundred thousand elements and 42 for a billion. An
// unbalanced BST can be n levels deep, which is why its code had to avoid recursion. Iteration still
// uses an explicit stack, so an iterator is a small value that never touches the call stack.
//
// Why a struct with copy-on-write: a class would be simpler, but then `var b = a; b.insert(4)` would
// change `a` too, unlike every other Swift collection. So the nodes live in a private `Storage` object
// that copies share, and every mutating method first checks `isKnownUniquelyReferenced(&storage)`. If
// another copy (or an iterator) can still see the storage, the tree copies its nodes before changing
// anything (M11 · Writing your own copy-on-write). Copying a tree is O(1) until the first change; the
// first change to a shared tree costs O(n). Nodes never leak out of the type, so two storages never
// share a node.

// MARK: - The balanced core

/// The AVL machinery shared by `AVLTree`, `SortedSet` and `SortedMap`: a binary search tree of
/// key-value nodes with value semantics. Sets use `Void` for the value.
struct AVLCore<Key: Comparable, Value> {
    final class Node {
        var key: Key
        var value: Value
        var left: Node?
        var right: Node?
        /// The number of levels in the subtree rooted here: 1 for a leaf.
        var height = 1

        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }

    /// The nodes of one tree, shared by copies until one of them changes.
    final class Storage {
        var root: Node?
        var count = 0

        init() {}

        /// A copy with brand-new nodes in the same shape. O(n); the recursion is O(log n) deep.
        func copy() -> Storage {
            let result = Storage()
            result.root = Self.clone(root)
            result.count = count
            return result
        }

        private static func clone(_ node: Node?) -> Node? {
            guard let node else { return nil }
            let fresh = Node(key: node.key, value: node.value)
            fresh.height = node.height
            fresh.left = clone(node.left)
            fresh.right = clone(node.right)
            return fresh
        }
    }

    private(set) var storage = Storage()

    init() {}

    var count: Int { storage.count }

    var root: Node? { storage.root }

    /// The number of levels: 0 when empty, 1 for a single node. O(1).
    var height: Int { Self.height(storage.root) }

    /// Gives this tree its own nodes if any other copy or iterator can see them.
    private mutating func makeUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = storage.copy()
        }
    }

    // MARK: Heights, balance factors and rotations

    static func height(_ node: Node?) -> Int {
        node?.height ?? 0
    }

    static func balanceFactor(_ node: Node) -> Int {
        height(node.left) - height(node.right)
    }

    private static func updateHeight(_ node: Node) {
        node.height = 1 + Swift.max(height(node.left), height(node.right))
    }

    /// Lifts the left child above `node` and returns it, the new root of this subtree:
    ///
    ///         node            pivot
    ///         /  \            /  \
    ///     pivot   C   →      A   node
    ///      / \                   /  \
    ///     A   B                 B    C
    ///
    /// Inorder order (A, pivot, B, node, C) is unchanged. O(1).
    private static func rotateRight(_ node: Node) -> Node {
        let pivot = node.left!
        node.left = pivot.right
        pivot.right = node
        updateHeight(node)                       // node is now below pivot, so it goes first
        updateHeight(pivot)
        return pivot
    }

    /// The mirror image of `rotateRight`: lifts the right child above `node`. O(1).
    private static func rotateLeft(_ node: Node) -> Node {
        let pivot = node.right!
        node.right = pivot.left
        pivot.left = node
        updateHeight(node)
        updateHeight(pivot)
        return pivot
    }

    /// Recomputes `node`'s height and, if its balance factor has reached 2 or -2, rotates to fix it.
    /// Returns the subtree's new root. Choosing single or double rotations by the child's balance factor
    /// (rather than by the key just inserted) makes this work after removals too. O(1).
    private static func rebalance(_ node: Node) -> Node {
        updateHeight(node)
        let factor = balanceFactor(node)
        if factor > 1 {
            if balanceFactor(node.left!) < 0 {
                node.left = rotateLeft(node.left!)     // left-right: straighten the bend first
            }
            return rotateRight(node)                   // left-left
        }
        if factor < -1 {
            if balanceFactor(node.right!) > 0 {
                node.right = rotateRight(node.right!)  // right-left
            }
            return rotateLeft(node)                    // right-right
        }
        return node
    }

    // MARK: Lookups

    /// The node holding `key`, or nil. O(log n).
    func node(for key: Key) -> Node? {
        var current = storage.root
        while let node = current {
            if key < node.key {
                current = node.left
            } else if node.key < key {
                current = node.right
            } else {
                return node
            }
        }
        return nil
    }

    /// The node with the largest key ≤ `key` (or < `key` when not inclusive), or nil. O(log n).
    func floorNode(_ key: Key, inclusive: Bool) -> Node? {
        var best: Node?
        var current = storage.root
        while let node = current {
            if node.key < key || (inclusive && node.key == key) {
                best = node                      // a candidate; anything better is to its right
                current = node.right
            } else {
                current = node.left
            }
        }
        return best
    }

    /// The node with the smallest key ≥ `key` (or > `key` when not inclusive), or nil. O(log n).
    func ceilingNode(_ key: Key, inclusive: Bool) -> Node? {
        var best: Node?
        var current = storage.root
        while let node = current {
            if key < node.key || (inclusive && node.key == key) {
                best = node                      // a candidate; anything better is to its left
                current = node.left
            } else {
                current = node.right
            }
        }
        return best
    }

    /// The node with the smallest key, or nil when empty. O(log n).
    var firstNode: Node? {
        var current = storage.root
        while let left = current?.left {
            current = left
        }
        return current
    }

    /// The node with the largest key, or nil when empty. O(log n).
    var lastNode: Node? {
        var current = storage.root
        while let right = current?.right {
            current = right
        }
        return current
    }

    /// The entries with keys from `lower` up to `upper` (including `upper` only if asked), in order.
    /// One descent finds the first key ≥ `lower`; an inorder walk then stops at the first key past
    /// `upper`. O(log n + k) for k results.
    func entries(from lower: Key, to upper: Key, includingUpper: Bool) -> [(key: Key, value: Value)] {
        var result: [(key: Key, value: Value)] = []
        var stack: [Node] = []
        var current = storage.root
        while let node = current {
            if node.key < lower {
                current = node.right             // too small, and so is its left subtree
            } else {
                stack.append(node)               // in range so far: visit it after its left subtree
                current = node.left
            }
        }
        while let node = stack.popLast() {
            if includingUpper ? upper < node.key : !(node.key < upper) {
                break
            }
            result.append((node.key, node.value))
            current = node.right
            while let next = current {
                stack.append(next)
                current = next.left
            }
        }
        return result
    }

    // MARK: Changes

    /// Inserts `key` if it isn't there yet, leaving an existing entry untouched. Returns true if it
    /// inserted. O(log n).
    @discardableResult
    mutating func insertIfAbsent(_ key: Key, _ value: Value) -> Bool {
        if node(for: key) != nil {
            return false
        }
        makeUnique()
        storage.root = Self.insert(key, value, into: storage.root)
        storage.count += 1
        return true
    }

    /// Sets the value for `key`, inserting it if needed. Returns the old value, or nil if the key is
    /// new. O(log n).
    @discardableResult
    mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        makeUnique()
        if let node = node(for: key) {
            let old = node.value
            node.value = value
            return old
        }
        storage.root = Self.insert(key, value, into: storage.root)
        storage.count += 1
        return nil
    }

    /// Removes `key` and returns its entry, or returns nil if it isn't there. O(log n).
    @discardableResult
    mutating func remove(_ key: Key) -> (key: Key, value: Value)? {
        guard node(for: key) != nil else { return nil }
        makeUnique()
        var removed: (key: Key, value: Value)?
        storage.root = Self.remove(key, from: storage.root, removed: &removed)
        storage.count -= 1
        return removed
    }

    /// Removes everything. O(1), plus releasing the nodes.
    mutating func removeAll() {
        storage = Storage()
    }

    /// An ordinary BST insert of a key that isn't in the tree, rebalancing each node on the way back
    /// up. Returns the subtree's new root.
    private static func insert(_ key: Key, _ value: Value, into node: Node?) -> Node {
        guard let node else { return Node(key: key, value: value) }
        if key < node.key {
            node.left = insert(key, value, into: node.left)
        } else {
            node.right = insert(key, value, into: node.right)
        }
        return rebalance(node)
    }

    /// An ordinary BST removal, rebalancing every node on the way back up. A node with two children
    /// takes its successor's entry, and the successor is removed from the right subtree instead.
    private static func remove(_ key: Key, from node: Node?, removed: inout (key: Key, value: Value)?) -> Node? {
        guard let node else { return nil }
        if key < node.key {
            node.left = remove(key, from: node.left, removed: &removed)
        } else if node.key < key {
            node.right = remove(key, from: node.right, removed: &removed)
        } else {
            removed = (node.key, node.value)
            guard let left = node.left else { return node.right }
            guard let right = node.right else { return left }
            var successor: (key: Key, value: Value)?
            node.right = removeMin(from: right, removed: &successor)
            node.key = successor!.key
            node.value = successor!.value
        }
        return rebalance(node)
    }

    /// Removes the smallest entry in the subtree at `node`, reporting it through `removed`.
    private static func removeMin(from node: Node, removed: inout (key: Key, value: Value)?) -> Node? {
        guard let left = node.left else {
            removed = (node.key, node.value)
            return node.right
        }
        node.left = removeMin(from: left, removed: &removed)
        return rebalance(node)
    }

    // MARK: Checking

    /// True when every invariant holds: keys strictly increase in inorder, every stored height is
    /// right, every balance factor is -1, 0 or 1, and `count` matches the nodes. For tests. O(n).
    func checkInvariants() -> Bool {
        var nodes = 0
        func check(_ node: Node?, above lower: Key?, below upper: Key?) -> Int? {
            guard let node else { return 0 }
            nodes += 1
            if let lower, !(lower < node.key) { return nil }
            if let upper, !(node.key < upper) { return nil }
            guard let left = check(node.left, above: lower, below: node.key),
                  let right = check(node.right, above: node.key, below: upper) else { return nil }
            let height = 1 + Swift.max(left, right)
            guard node.height == height, abs(left - right) <= 1 else { return nil }
            return height
        }
        return check(storage.root, above: nil, below: nil) != nil && nodes == storage.count
    }

    // MARK: Iteration

    /// Walks the entries in key order with an explicit stack of the nodes still to visit. Holding
    /// `storage` keeps the tree from being changed in place underneath it: a mutation copies instead.
    struct Iterator: IteratorProtocol {
        private let storage: Storage
        private var stack: [Node] = []

        init(_ storage: Storage) {
            self.storage = storage
            pushLeftEdge(from: storage.root)
        }

        private mutating func pushLeftEdge(from start: Node?) {
            var current = start
            while let node = current {
                stack.append(node)
                current = node.left
            }
        }

        mutating func next() -> (key: Key, value: Value)? {
            guard let node = stack.popLast() else { return nil }
            pushLeftEdge(from: node.right)
            return (node.key, node.value)
        }
    }

    func makeIterator() -> Iterator {
        Iterator(storage)
    }
}

// MARK: - AVLTree

/// A self-balancing binary search tree holding each element at most once: O(log n) insert, remove,
/// contains, min, max, floor and ceiling, whatever order the elements arrive in.
///
/// ```swift
/// var tree: AVLTree = [50, 20, 80]
/// tree.insert(30)                 // true
/// tree.insert(30)                 // false: already there
/// tree.floor(45)                  // Optional(30), the largest element ≤ 45
/// tree.ceiling(45)                // Optional(50), the smallest element ≥ 45
/// print(Array(tree))              // [20, 30, 50, 80]
/// ```
///
/// Feeding it sorted input, the worst case for a plain BST, still gives a tree about log2 n levels
/// tall. It's a value type with copy-on-write, and a `Sequence` that visits elements in increasing
/// order. For a collection-style API with range queries, use `SortedSet` or `SortedMap`.
public struct AVLTree<Element: Comparable> {
    var core = AVLCore<Element, Void>()

    /// Creates an empty tree. O(1).
    public init() {}

    /// Creates a tree holding the distinct elements of `elements`. O(n log n).
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            insert(element)
        }
    }

    /// The number of elements. O(1).
    public var count: Int {
        core.count
    }

    /// True when the tree holds no elements. O(1).
    public var isEmpty: Bool {
        core.count == 0
    }

    /// The number of levels: 0 when empty, 1 for a single element. Always below about
    /// 1.44 log2(count + 2). O(1).
    public var height: Int {
        core.height
    }

    /// Inserts `element` if it isn't already there. Returns true if it was inserted, false if an
    /// equal element was already in the tree (which is left as it was). O(log n).
    @discardableResult
    public mutating func insert(_ element: Element) -> Bool {
        core.insertIfAbsent(element, ())
    }

    /// Removes `element` and returns the stored element equal to it, or nil if there wasn't one.
    /// O(log n).
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        core.remove(element)?.key
    }

    /// Removes every element. O(n) to release the nodes.
    public mutating func removeAll() {
        core.removeAll()
    }

    /// True if an element equal to `element` is in the tree. O(log n), unlike the O(n) `contains`
    /// every sequence has.
    public func contains(_ element: Element) -> Bool {
        core.node(for: element) != nil
    }

    /// The smallest element, or nil when empty. O(log n).
    public func min() -> Element? {
        core.firstNode?.key
    }

    /// The largest element, or nil when empty. O(log n).
    public func max() -> Element? {
        core.lastNode?.key
    }

    /// The largest element less than or equal to `element`, or nil if every element is bigger.
    /// O(log n).
    public func floor(_ element: Element) -> Element? {
        core.floorNode(element, inclusive: true)?.key
    }

    /// The smallest element greater than or equal to `element`, or nil if every element is smaller.
    /// O(log n).
    public func ceiling(_ element: Element) -> Element? {
        core.ceilingNode(element, inclusive: true)?.key
    }

    /// True when every AVL invariant holds (search order, stored heights, balance factors and count).
    /// Used by the tests. O(n).
    var isBalanced: Bool {
        core.checkInvariants()
    }
}

extension AVLTree: Sequence {
    /// Visits the elements in increasing order, iteratively, with a stack of O(log n) nodes.
    public struct Iterator: IteratorProtocol {
        var base: AVLCore<Element, Void>.Iterator

        /// The next element in increasing order, or nil at the end. Amortised O(1), O(log n) worst case.
        public mutating func next() -> Element? {
            base.next()?.key
        }
    }

    /// An iterator over the elements in increasing order. Changing the tree during the loop doesn't
    /// affect it. O(log n).
    public func makeIterator() -> Iterator {
        Iterator(base: core.makeIterator())
    }

    /// The number of elements, so `Array(tree)` allocates once. O(1).
    public var underestimatedCount: Int {
        core.count
    }
}

extension AVLTree: ExpressibleByArrayLiteral {
    /// Creates a tree from an array literal. Repeated elements are stored once. O(n log n).
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension AVLTree: CustomStringConvertible {
    /// The elements in increasing order, for example `AVLTree([1, 2, 3])`. O(n).
    public var description: String {
        "AVLTree(\(Array(self)))"
    }
}

extension AVLTree: Equatable {
    /// Two trees are equal when they hold equal elements, whatever their shapes. O(n).
    public static func == (lhs: AVLTree, rhs: AVLTree) -> Bool {
        lhs.count == rhs.count && lhs.elementsEqual(rhs)
    }
}
