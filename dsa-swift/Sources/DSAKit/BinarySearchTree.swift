// The finished binary search tree from M37 (Build a generic BST<Element: Comparable>).
//
// Why a struct with copy-on-write rather than a class? A class would be simpler, but then
// `var b = a; b.insert(4)` would change `a` as well, unlike Swift's own Set and Array. So the nodes
// live in a private `Storage` object that copies of the tree share, and every mutating method first
// checks `isKnownUniquelyReferenced(&storage)`. If another copy can see the storage, the tree copies
// its nodes before changing anything (M11, Writing your own copy-on-write). Copying a tree is O(1)
// until the first change; that first change to a shared tree costs O(n) to copy the nodes. Nodes
// never leak out of the type, so two storages never share a node.
//
// The tree is a set: each element appears at most once, and inserting one that's already there
// changes nothing. It isn't balanced, so every operation that walks from the root costs O(h), where h
// is the height: O(log n) for random insertion orders, but O(n) for sorted ones (M37, Why unbalanced
// BSTs degrade to O(n)). M38 fixes that with rotations.
//
// A degenerate tree can be 100,000 levels deep, so nothing here recurses: insert, remove, copying,
// iteration and even freeing the nodes all use loops.

/// A binary search tree holding each element at most once, in sorted order. `insert`, `contains`,
/// `remove`, `min`, `max`, `floor` and `ceiling` are O(h), where h is the height: O(log n) when
/// elements arrive in random order, O(n) in the worst case (sorted input).
///
/// ```swift
/// var tree: BinarySearchTree = [50, 30, 70, 20, 40]
/// tree.insert(60)             // true
/// tree.insert(30)             // false: already there
/// tree.contains(40)           // true
/// tree.floor(45)              // Optional(40)
/// tree.remove(30)             // Optional(30)
/// Array(tree)                 // [20, 40, 50, 60, 70]
/// ```
///
/// `BinarySearchTree` is a value type and a `Sequence` whose elements come out in increasing order.
public struct BinarySearchTree<Element: Comparable> {
    final class Node {
        var value: Element
        var left: Node?
        var right: Node?

        init(_ value: Element) {
            self.value = value
        }

        // Releasing a node releases its children, which release theirs: one nested call per level,
        // enough to overflow the stack for a degenerate tree. So the children are unhooked with a
        // loop instead. A node still referenced elsewhere (by an iterator) is left alone.
        deinit {
            var pending: [Node] = []
            if let left { pending.append(left) }
            if let right { pending.append(right) }
            left = nil
            right = nil
            while var node = pending.popLast() {
                guard isKnownUniquelyReferenced(&node) else { continue }
                if let child = node.left {
                    pending.append(child)
                    node.left = nil
                }
                if let child = node.right {
                    pending.append(child)
                    node.right = nil
                }
            }
        }
    }

    /// The nodes of one tree, shared by copies of it until one of them changes.
    final class Storage {
        var root: Node?
        var count = 0

        init() {}

        /// A copy with brand-new nodes in the same shape. Iterative, so depth doesn't matter. O(n).
        func copy() -> Storage {
            let result = Storage()
            result.count = count
            guard let root else { return result }
            let rootCopy = Node(root.value)
            result.root = rootCopy
            var pending: [(original: Node, copy: Node)] = [(root, rootCopy)]
            while let (original, copy) = pending.popLast() {
                if let left = original.left {
                    let child = Node(left.value)
                    copy.left = child
                    pending.append((left, child))
                }
                if let right = original.right {
                    let child = Node(right.value)
                    copy.right = child
                    pending.append((right, child))
                }
            }
            return result
        }
    }

    private var storage = Storage()

    /// Creates an empty tree. O(1).
    public init() {}

    /// Creates a tree holding `elements`, inserted in order; repeats are ignored. O(n · h): sorted
    /// input builds a degenerate tree, so shuffle it first, or expect O(n²).
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            insert(element)
        }
    }

    /// The number of elements. O(1): the tree keeps count as it changes.
    public var count: Int {
        storage.count
    }

    /// True when the tree holds no elements. O(1).
    public var isEmpty: Bool {
        storage.root == nil
    }

    /// The node holding `element`, found by walking down from the root. O(h).
    private func node(holding element: Element) -> Node? {
        var current = storage.root
        while let node = current {
            if element < node.value {
                current = node.left
            } else if node.value < element {
                current = node.right
            } else {
                return node
            }
        }
        return nil
    }

    /// True if the tree holds `element`. O(h).
    public func contains(_ element: Element) -> Bool {
        node(holding: element) != nil
    }

    /// Adds `element` and returns true, or returns false and changes nothing if an equal element is
    /// already in the tree. O(h), plus O(n) the first time a shared copy changes.
    @discardableResult
    public mutating func insert(_ element: Element) -> Bool {
        if !isKnownUniquelyReferenced(&storage) {
            if contains(element) { return false }          // no change, so no need to copy
            storage = storage.copy()
        }
        guard var current = storage.root else {
            storage.root = Node(element)
            storage.count = 1
            return true
        }
        while true {
            if element < current.value {
                guard let left = current.left else {
                    current.left = Node(element)
                    break
                }
                current = left
            } else if current.value < element {
                guard let right = current.right else {
                    current.right = Node(element)
                    break
                }
                current = right
            } else {
                return false
            }
        }
        storage.count += 1
        return true
    }

    /// Removes `element` and returns the copy the tree held, or returns nil if it isn't there. A node
    /// with two children takes its inorder successor's value, and the successor (which has no left
    /// child) is unlinked instead. O(h), plus O(n) the first time a shared copy changes.
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        if !isKnownUniquelyReferenced(&storage) {
            guard contains(element) else { return nil }
            storage = storage.copy()
        }
        var parent: Node? = nil
        var current = storage.root
        while let node = current {
            if element < node.value {
                parent = node
                current = node.left
            } else if node.value < element {
                parent = node
                current = node.right
            } else {
                break
            }
        }
        guard let node = current else { return nil }
        let removed = node.value

        if let right = node.right, node.left != nil {
            // Two children: the successor is the leftmost node of the right subtree
            var successorParent = node
            var successor = right
            while let next = successor.left {
                successorParent = successor
                successor = next
            }
            node.value = successor.value
            if successorParent === node {
                node.right = successor.right
            } else {
                successorParent.left = successor.right
            }
            successor.right = nil
        } else {
            // No children, or one: the parent adopts the only child (or nil)
            let child = node.left ?? node.right
            node.left = nil
            node.right = nil
            if let parent {
                if parent.left === node {
                    parent.left = child
                } else {
                    parent.right = child
                }
            } else {
                storage.root = child
            }
        }
        storage.count -= 1
        return removed
    }

    /// Removes every element. O(n) to free the nodes (or O(1) if another copy still shares them).
    public mutating func removeAll() {
        storage = Storage()
    }

    /// The smallest element, or nil if the tree is empty: the leftmost node. O(h).
    public var min: Element? {
        guard var node = storage.root else { return nil }
        while let left = node.left {
            node = left
        }
        return node.value
    }

    /// The largest element, or nil if the tree is empty: the rightmost node. O(h).
    public var max: Element? {
        guard var node = storage.root else { return nil }
        while let right = node.right {
            node = right
        }
        return node.value
    }

    /// The largest element less than or equal to `element`, or nil if every element is bigger. O(h).
    public func floor(_ element: Element) -> Element? {
        var best: Element? = nil
        var current = storage.root
        while let node = current {
            if node.value < element {
                best = node.value                          // a candidate; look for a bigger one
                current = node.right
            } else if element < node.value {
                current = node.left
            } else {
                return node.value
            }
        }
        return best
    }

    /// The smallest element greater than or equal to `element`, or nil if every element is smaller.
    /// O(h).
    public func ceiling(_ element: Element) -> Element? {
        var best: Element? = nil
        var current = storage.root
        while let node = current {
            if element < node.value {
                best = node.value                          // a candidate; look for a smaller one
                current = node.left
            } else if node.value < element {
                current = node.right
            } else {
                return node.value
            }
        }
        return best
    }

    /// The number of levels: 0 for an empty tree, 1 for a single element, and n for a degenerate
    /// tree of n elements. Counted level by level, without recursion. O(n).
    public var height: Int {
        var levels = 0
        var level: [Node] = storage.root.map { [$0] } ?? []
        while !level.isEmpty {
            levels += 1
            var next: [Node] = []
            for node in level {
                if let left = node.left { next.append(left) }
                if let right = node.right { next.append(right) }
            }
            level = next
        }
        return levels
    }
}

extension BinarySearchTree: Sequence {
    /// Walks the tree in increasing order with a stack of the nodes still to visit: at most one per
    /// level, so O(h) memory. Each `next()` is amortised O(1): every node is pushed and popped once.
    public struct Iterator: IteratorProtocol {
        /// Keeps the tree's storage alive and shared while iterating, so changing the tree during a
        /// `for` loop copies it first instead of changing the nodes under this iterator.
        private let storage: Storage
        private var stack: [Node] = []

        init(_ storage: Storage) {
            self.storage = storage
            pushLeftSpine(from: storage.root)
        }

        /// Pushes `start` and its chain of left children: the next smallest is on top.
        private mutating func pushLeftSpine(from start: Node?) {
            var current = start
            while let node = current {
                stack.append(node)
                current = node.left
            }
        }

        /// The next element in increasing order, or nil when every element has been visited.
        /// Amortised O(1).
        public mutating func next() -> Element? {
            guard let node = stack.popLast() else { return nil }
            pushLeftSpine(from: node.right)
            return node.value
        }
    }

    /// An iterator over the elements in increasing order. O(h).
    public func makeIterator() -> Iterator {
        Iterator(storage)
    }

    /// The number of elements, so `Array(tree)` allocates once. O(1).
    public var underestimatedCount: Int {
        storage.count
    }
}

extension BinarySearchTree: ExpressibleByArrayLiteral {
    /// Creates a tree from an array literal, inserting the elements in order and ignoring repeats.
    /// O(n · h).
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension BinarySearchTree: CustomStringConvertible {
    /// The elements in increasing order, for example `BinarySearchTree([1, 2, 3])`. O(n).
    public var description: String {
        "BinarySearchTree(\(Array(self)))"
    }
}

extension BinarySearchTree: Equatable {
    /// Two trees are equal when they hold the same elements. Their shapes don't matter: `[2, 1, 3]`
    /// and `[1, 2, 3]` are equal, though the first is balanced and the second is a chain. O(n).
    public static func == (lhs: BinarySearchTree, rhs: BinarySearchTree) -> Bool {
        lhs.count == rhs.count && lhs.elementsEqual(rhs)
    }
}
