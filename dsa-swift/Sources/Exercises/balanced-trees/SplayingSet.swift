// Problem: A splay tree set (M38 · Splay trees)

public enum SplayingSet {
    /// One node of the tree. Written for you.
    public final class Node {
        public let key: Int
        public var left: Node?
        public var right: Node?

        public init(_ key: Int) {
            self.key = key
        }

        // Releasing a long chain node by node would nest one call per level; this unhooks the
        // children with a loop instead, so even a very deep tree is freed safely.
        deinit {
            var pending: [Node] = []
            if let left { pending.append(left) }
            if let right { pending.append(right) }
            left = nil
            right = nil
            while var node = pending.popLast() {
                guard isKnownUniquelyReferenced(&node) else { continue }
                if let child = node.left { pending.append(child); node.left = nil }
                if let child = node.right { pending.append(child); node.right = nil }
            }
        }
    }

    /// A set of Ints in a splay tree: every operation splays the key it touched (or, on a miss, the
    /// last node it visited) to the root, using zig, zig-zig (grandparent first) and zig-zag steps.
    public final class SplaySet {
        /// The root node, or nil when the set is empty. Only the set itself changes it.
        public private(set) var root: Node?

        /// How many keys the set holds.
        public private(set) var count = 0

        public init() {}

        /// True if `key` is in the set. Afterwards the root holds `key`, or the last node visited.
        public func contains(_ key: Int) -> Bool {
            // Write your solution here, then run:
            // swift test --filter SplayingSetTests
            return false
        }

        /// Inserts `key`, returning true if it was new. Afterwards the root holds `key`.
        @discardableResult
        public func insert(_ key: Int) -> Bool {
            return false
        }

        /// Removes `key`, returning true if it was there. On a hit, the left subtree's largest key
        /// becomes the root (if there's a left subtree); on a miss, the last node visited does.
        @discardableResult
        public func remove(_ key: Int) -> Bool {
            return false
        }

        // Written for you ───────────────────────────────────────────────────────────────────────

        /// The keys in increasing order (an inorder walk with a stack). O(n).
        public var sortedKeys: [Int] {
            var result: [Int] = []
            var stack: [Node] = []
            var current = root
            while current != nil || !stack.isEmpty {
                while let node = current {
                    stack.append(node)
                    current = node.left
                }
                let node = stack.removeLast()
                result.append(node.key)
                current = node.right
            }
            return result
        }

        /// The number of levels: 0 when empty. Uses a stack, so a long chain is fine. O(n).
        public var height: Int {
            var tallest = 0
            var stack: [(Node, Int)] = root.map { [($0, 1)] } ?? []
            while let (node, depth) = stack.popLast() {
                tallest = max(tallest, depth)
                if let left = node.left { stack.append((left, depth + 1)) }
                if let right = node.right { stack.append((right, depth + 1)) }
            }
            return tallest
        }
    }
}
