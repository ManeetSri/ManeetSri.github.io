// Reference solution: Build an AVL tree. Ordinary recursive BST insert and remove, where each call
// returns the new root of its subtree. On the way back up, every node recomputes its height and, if its
// balance factor has reached ±2, rotates: once if the taller child leans the same way (left-left,
// right-right), twice if it leans the other way (left-right, right-left). Choosing by the child's balance
// factor rather than the inserted value makes the same `rebalance` work after removals. The recursion is
// as deep as the tree, at most about 1.44 log2(n + 2) levels. O(log n) per operation.

public enum AVLSetFromScratch {
    public final class Node {
        public var value: Int
        public var left: Node?
        public var right: Node?
        public var height = 1

        public init(_ value: Int) {
            self.value = value
        }
    }

    public final class AVLSet {
        public private(set) var root: Node?
        public private(set) var count = 0

        public init() {}

        public func contains(_ value: Int) -> Bool {
            var current = root
            while let node = current {
                if value == node.value { return true }
                current = value < node.value ? node.left : node.right
            }
            return false
        }

        @discardableResult
        public func insert(_ value: Int) -> Bool {
            guard !contains(value) else { return false }
            root = Self.insert(value, into: root)
            count += 1
            return true
        }

        @discardableResult
        public func remove(_ value: Int) -> Bool {
            guard contains(value) else { return false }
            root = Self.remove(value, from: root)
            count -= 1
            return true
        }

        // MARK: Rebalancing

        private static func height(_ node: Node?) -> Int {
            node?.height ?? 0
        }

        private static func balance(_ node: Node) -> Int {
            height(node.left) - height(node.right)
        }

        private static func update(_ node: Node) {
            node.height = 1 + max(height(node.left), height(node.right))
        }

        private static func rotateRight(_ node: Node) -> Node {
            let pivot = node.left!
            node.left = pivot.right
            pivot.right = node
            update(node)                                 // node is below pivot now: update it first
            update(pivot)
            return pivot
        }

        private static func rotateLeft(_ node: Node) -> Node {
            let pivot = node.right!
            node.right = pivot.left
            pivot.left = node
            update(node)
            update(pivot)
            return pivot
        }

        private static func rebalance(_ node: Node) -> Node {
            update(node)
            let factor = balance(node)
            if factor > 1 {
                if balance(node.left!) < 0 {
                    node.left = rotateLeft(node.left!)      // left-right
                }
                return rotateRight(node)                    // left-left
            }
            if factor < -1 {
                if balance(node.right!) > 0 {
                    node.right = rotateRight(node.right!)   // right-left
                }
                return rotateLeft(node)                     // right-right
            }
            return node
        }

        // MARK: Insert and remove

        private static func insert(_ value: Int, into node: Node?) -> Node {
            guard let node else { return Node(value) }
            if value < node.value {
                node.left = insert(value, into: node.left)
            } else {
                node.right = insert(value, into: node.right)
            }
            return rebalance(node)
        }

        private static func remove(_ value: Int, from node: Node?) -> Node? {
            guard let node else { return nil }
            if value < node.value {
                node.left = remove(value, from: node.left)
            } else if value > node.value {
                node.right = remove(value, from: node.right)
            } else {
                guard let left = node.left else { return node.right }
                guard let right = node.right else { return left }
                var successor = right
                while let smaller = successor.left {
                    successor = smaller
                }
                node.value = successor.value
                node.right = remove(successor.value, from: right)
            }
            return rebalance(node)
        }

        // MARK: Written for you in the exercise

        public var height: Int {
            root?.height ?? 0
        }

        public var sorted: [Int] {
            var result: [Int] = []
            var stack: [Node] = []
            var current = root
            while current != nil || !stack.isEmpty {
                while let node = current {
                    stack.append(node)
                    current = node.left
                }
                let node = stack.removeLast()
                result.append(node.value)
                current = node.right
            }
            return result
        }

        public var levelOrder: [Int?] {
            var result: [Int?] = []
            var queue: [Node?] = [root]
            var head = 0
            while head < queue.count {
                let node = queue[head]
                head += 1
                if let node {
                    result.append(node.value)
                    queue.append(node.left)
                    queue.append(node.right)
                } else {
                    result.append(nil)
                }
            }
            while let last = result.last, last == nil {
                result.removeLast()
            }
            return result
        }
    }
}
