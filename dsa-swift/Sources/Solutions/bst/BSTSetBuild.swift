// Reference solution: Build a binary search tree set. Class nodes inside a struct. Every operation walks
// one path from the root, with loops rather than recursion so a degenerate tree can't overflow the
// stack: O(h) each, for a tree of height h. Removing a node with two children copies in its inorder
// successor and unlinks the successor, which has no left child. `inOrder` is an iterative inorder walk,
// O(n). (DSAKit's BinarySearchTree adds copy-on-write, Sequence and more.)

public enum BSTSetBuild {
    public struct SearchTreeSet<Element: Comparable> {
        final class Node {
            var value: Element
            var left: Node?
            var right: Node?

            init(_ value: Element) {
                self.value = value
            }
        }

        private var root: Node?
        public private(set) var count = 0

        public init() {}

        public var isEmpty: Bool {
            root == nil
        }

        public func contains(_ element: Element) -> Bool {
            var current = root
            while let node = current {
                if element < node.value {
                    current = node.left
                } else if node.value < element {
                    current = node.right
                } else {
                    return true
                }
            }
            return false
        }

        @discardableResult
        public mutating func insert(_ element: Element) -> Bool {
            guard var node = root else {
                root = Node(element)
                count = 1
                return true
            }
            while true {
                if element < node.value {
                    guard let left = node.left else {
                        node.left = Node(element)
                        break
                    }
                    node = left
                } else if node.value < element {
                    guard let right = node.right else {
                        node.right = Node(element)
                        break
                    }
                    node = right
                } else {
                    return false
                }
            }
            count += 1
            return true
        }

        @discardableResult
        public mutating func remove(_ element: Element) -> Element? {
            var parent: Node? = nil
            var current = root
            while let node = current, node.value != element {
                parent = node
                current = element < node.value ? node.left : node.right
            }
            guard let node = current else { return nil }
            let removed = node.value
            if let right = node.right, node.left != nil {
                var successorParent = node
                var successor = right
                while let smaller = successor.left {
                    successorParent = successor
                    successor = smaller
                }
                node.value = successor.value
                if successorParent === node {
                    node.right = successor.right
                } else {
                    successorParent.left = successor.right
                }
            } else {
                let child = node.left ?? node.right
                if let parent {
                    if parent.left === node {
                        parent.left = child
                    } else {
                        parent.right = child
                    }
                } else {
                    root = child
                }
            }
            count -= 1
            return removed
        }

        public var min: Element? {
            guard var node = root else { return nil }
            while let left = node.left {
                node = left
            }
            return node.value
        }

        public var max: Element? {
            guard var node = root else { return nil }
            while let right = node.right {
                node = right
            }
            return node.value
        }

        public func floor(_ element: Element) -> Element? {
            var best: Element? = nil
            var current = root
            while let node = current {
                if node.value == element {
                    return node.value
                } else if node.value < element {
                    best = node.value
                    current = node.right
                } else {
                    current = node.left
                }
            }
            return best
        }

        public func ceiling(_ element: Element) -> Element? {
            var best: Element? = nil
            var current = root
            while let node = current {
                if node.value == element {
                    return node.value
                } else if node.value > element {
                    best = node.value
                    current = node.left
                } else {
                    current = node.right
                }
            }
            return best
        }

        public var inOrder: [Element] {
            var result: [Element] = []
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
    }
}
