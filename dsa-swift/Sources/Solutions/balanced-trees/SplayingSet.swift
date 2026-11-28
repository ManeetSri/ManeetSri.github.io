// Reference solution: A splay tree set. A recursive bottom-up splay brings a key, or the last node on
// its search path, to the top of a subtree two levels per call: zig-zig rotates at the grandparent
// first, zig-zag is a double rotation, and a final zig is one rotation. contains splays; insert splays
// and puts the new key above the old root; remove splays, then splays the left subtree's largest key
// up and hangs the right subtree on it. O(log n) amortised per operation.

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

    public final class SplaySet {
        public private(set) var root: Node?
        public private(set) var count = 0

        public init() {}

        public func contains(_ key: Int) -> Bool {
            root = Self.splay(root, key)
            return root?.key == key
        }

        @discardableResult
        public func insert(_ key: Int) -> Bool {
            guard let top = Self.splay(root, key) else {
                root = Node(key)
                count = 1
                return true
            }
            if top.key == key { root = top; return false }
            let node = Node(key)
            if key < top.key {
                node.left = top.left                     // smaller keys stay on the left
                node.right = top
                top.left = nil
            } else {
                node.right = top.right
                node.left = top
                top.right = nil
            }
            root = node
            count += 1
            return true
        }

        @discardableResult
        public func remove(_ key: Int) -> Bool {
            root = Self.splay(root, key)
            guard let top = root, top.key == key else { return false }
            if let left = top.left {
                let joined = Self.splay(left, key)!      // the largest key of the left subtree…
                joined.right = top.right                 // …has no right child: hang the right subtree there
                root = joined
            } else {
                root = top.right
            }
            count -= 1
            return true
        }

        private static func rotateRight(_ y: Node) -> Node {
            let x = y.left!
            y.left = x.right
            x.right = y
            return x
        }

        private static func rotateLeft(_ x: Node) -> Node {
            let y = x.right!
            x.right = y.left
            y.left = x
            return y
        }

        /// Brings key, or the last node on its search path, to the top of this subtree.
        private static func splay(_ root: Node?, _ key: Int) -> Node? {
            guard let root, root.key != key else { return root }
            if key < root.key {
                guard let child = root.left else { return root }
                if key < child.key {                                       // zig-zig
                    child.left = splay(child.left, key)
                    let lifted = rotateRight(root)                         // grandparent first
                    return lifted.left == nil ? lifted : rotateRight(lifted)
                } else if key > child.key {                                // zig-zag
                    child.right = splay(child.right, key)
                    if child.right != nil { root.left = rotateLeft(child) }
                    return root.left == nil ? root : rotateRight(root)
                }
                return rotateRight(root)                                   // zig
            } else {
                guard let child = root.right else { return root }
                if key > child.key {
                    child.right = splay(child.right, key)
                    let lifted = rotateLeft(root)
                    return lifted.right == nil ? lifted : rotateLeft(lifted)
                } else if key < child.key {
                    child.left = splay(child.left, key)
                    if child.left != nil { root.right = rotateRight(child) }
                    return root.right == nil ? root : rotateLeft(root)
                }
                return rotateLeft(root)
            }
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
