// Reference solution: Climbing a tree with weak parents. Children are strong and the parent pointer is weak,
// so a tree is freed as soon as its root is. Walking up takes O(depth) time and O(1) extra space
// (pathToRoot uses O(depth) for its result).

public enum WeakParentTree {
    public final class Node {
        public let value: Int
        public private(set) var children: [Node] = []
        public private(set) weak var parent: Node?

        public init(_ value: Int) {
            self.value = value
        }

        public func addChild(_ child: Node) {
            child.parent?.children.removeAll { $0 === child }
            children.append(child)
            child.parent = self
        }

        public var depth: Int {
            var steps = 0
            var current = parent
            while let node = current {
                steps += 1
                current = node.parent
            }
            return steps
        }

        public var pathToRoot: [Int] {
            var path: [Int] = []
            var current: Node? = self
            while let node = current {
                path.append(node.value)
                current = node.parent
            }
            return path
        }

        public var root: Node {
            var top = self
            while let next = top.parent {
                top = next
            }
            return top
        }
    }
}
