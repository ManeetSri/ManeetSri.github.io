// Reference solution: LRU cache. A dictionary finds a key's node in O(1), and a doubly linked list keeps
// the nodes in order of use, most recent at the head. Using a key unlinks its node and pushes it on the
// front, both O(1) because the node knows its neighbours. When the cache overflows, the tail is the least
// recently used node: unlink it and remove its key. `previous` is weak so neighbours don't keep each
// other alive (M11); the dictionary and the `next` chain own the nodes.

public enum LRUCache {
    public final class Cache<Key: Hashable, Value> {
        final class Node {
            let key: Key
            var value: Value
            var next: Node?
            weak var previous: Node?

            init(key: Key, value: Value) {
                self.key = key
                self.value = value
            }
        }

        public let capacity: Int
        private var nodes: [Key: Node] = [:]
        private var head: Node?      // most recently used
        private var tail: Node?      // least recently used

        public init(capacity: Int) {
            precondition(capacity > 0, "An LRU cache needs room for at least one entry")
            self.capacity = capacity
        }

        public var count: Int { nodes.count }

        /// Takes `node` out of the list, joining its neighbours. O(1).
        private func unlink(_ node: Node) {
            let before = node.previous
            let after = node.next
            if let before {
                before.next = after
            } else {
                head = after
            }
            if let after {
                after.previous = before
            } else {
                tail = before
            }
            node.next = nil
            node.previous = nil
        }

        /// Puts `node` at the front of the list. O(1).
        private func pushFront(_ node: Node) {
            node.next = head
            head?.previous = node
            head = node
            if tail == nil {
                tail = node
            }
        }

        public func value(for key: Key) -> Value? {
            guard let node = nodes[key] else { return nil }
            if node !== head {
                unlink(node)
                pushFront(node)
            }
            return node.value
        }

        public func setValue(_ value: Value, for key: Key) {
            if let node = nodes[key] {
                node.value = value
                if node !== head {
                    unlink(node)
                    pushFront(node)
                }
                return
            }
            let node = Node(key: key, value: value)
            nodes[key] = node
            pushFront(node)
            if nodes.count > capacity, let oldest = tail {
                unlink(oldest)
                nodes[oldest.key] = nil
            }
        }

        @discardableResult
        public func removeValue(for key: Key) -> Value? {
            guard let node = nodes.removeValue(forKey: key) else { return nil }
            unlink(node)
            return node.value
        }

        public var keysByRecency: [Key] {
            var keys: [Key] = []
            var current = head
            while let node = current {
                keys.append(node.key)
                current = node.next
            }
            return keys
        }
    }
}
