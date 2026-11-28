// Reference solution: LFU cache. A dictionary finds a key's node in O(1). Nodes with the same use count
// live in one doubly linked list per count ("bucket"), most recently used at the head, and
// `minFrequency` names the lowest count present. A use moves a node from bucket c to the head of bucket
// c + 1; if that empties the lowest bucket, the minimum rises by exactly 1. Eviction takes the tail of the
// lowest bucket: the least recently used of the least frequently used. Every operation is O(1) on
// average. `previous` is weak, so neighbours don't keep each other alive.

public enum LFUCache {
    public final class Cache<Key: Hashable, Value> {
        final class Node {
            let key: Key
            var value: Value
            var frequency = 1
            var next: Node?
            weak var previous: Node?

            init(key: Key, value: Value) {
                self.key = key
                self.value = value
            }
        }

        /// One count's nodes, most recently used at the head.
        final class Bucket {
            var head: Node?
            var tail: Node?

            var isEmpty: Bool { head == nil }

            func pushFront(_ node: Node) {
                node.next = head
                node.previous = nil
                head?.previous = node
                head = node
                if tail == nil { tail = node }
            }

            func unlink(_ node: Node) {
                let before = node.previous
                let after = node.next
                if let before { before.next = after } else { head = after }
                if let after { after.previous = before } else { tail = before }
                node.next = nil
                node.previous = nil
            }
        }

        public let capacity: Int
        private var nodes: [Key: Node] = [:]
        private var buckets: [Int: Bucket] = [:]
        private var minFrequency = 0

        public init(capacity: Int) {
            self.capacity = max(0, capacity)
        }

        public var count: Int { nodes.count }

        private func bucket(for frequency: Int) -> Bucket {
            if let bucket = buckets[frequency] { return bucket }
            let bucket = Bucket()
            buckets[frequency] = bucket
            return bucket
        }

        /// A use: move the node up one bucket. O(1).
        private func touch(_ node: Node) {
            let old = buckets[node.frequency]!
            old.unlink(node)
            if old.isEmpty {
                buckets[node.frequency] = nil
                if minFrequency == node.frequency { minFrequency += 1 }
            }
            node.frequency += 1
            bucket(for: node.frequency).pushFront(node)
        }

        public func value(for key: Key) -> Value? {
            guard let node = nodes[key] else { return nil }
            touch(node)
            return node.value
        }

        public func setValue(_ value: Value, for key: Key) {
            guard capacity > 0 else { return }
            if let node = nodes[key] {
                node.value = value
                touch(node)
                return
            }
            if nodes.count == capacity, let lowest = buckets[minFrequency], let victim = lowest.tail {
                lowest.unlink(victim)
                if lowest.isEmpty { buckets[minFrequency] = nil }
                nodes[victim.key] = nil
            }
            let node = Node(key: key, value: value)
            nodes[key] = node
            bucket(for: 1).pushFront(node)
            minFrequency = 1
        }

        public func frequency(of key: Key) -> Int {
            nodes[key]?.frequency ?? 0
        }

        public var evictionOrder: [Key] {
            var keys: [Key] = []
            for frequency in buckets.keys.sorted() {
                var current = buckets[frequency]!.tail
                while let node = current {
                    keys.append(node.key)
                    current = node.previous
                }
            }
            return keys
        }
    }
}
