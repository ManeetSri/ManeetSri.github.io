// Problem: Climbing a tree with weak parents (M11 · weak and unowned references)

public enum WeakParentTree {
    public final class Node {
        public let value: Int
        /// This node's children, in the order they were added. A node keeps its children alive.
        public private(set) var children: [Node] = []
        /// The node this one hangs from, or nil for a root. This pointer must not keep the parent alive.
        public private(set) var parent: Node?

        public init(_ value: Int) {
            self.value = value
        }

        /// Adds `child` as this node's last child and makes this node its parent. If the child already had
        /// a parent, it's moved: it's removed from the old parent's children first.
        public func addChild(_ child: Node) {
            // Write your solution here, then run:
            // swift test --filter WeakParentTreeTests
        }

        /// The number of steps up to the root. A root has depth 0.
        public var depth: Int {
            return 0
        }

        /// The values from this node up to the root, both included: [value, parent's value, ..., root's value].
        public var pathToRoot: [Int] {
            return []
        }

        /// The topmost ancestor of this node, or the node itself if it has no parent.
        public var root: Node {
            return self
        }
    }
}
