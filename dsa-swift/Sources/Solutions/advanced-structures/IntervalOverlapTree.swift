// Reference solution: an interval tree built on a treap. Nodes are ordered by (start, id), so equal
// starts are fine, and each node also stores maxEnd, the largest end in its subtree, recomputed whenever
// split or merge rebuilds a node. Random priorities keep the treap O(log n) deep for any insertion order,
// including sorted. A query skips any subtree whose maxEnd is before the query's start, and the right
// subtree of any node that starts after the query's end. A dictionary from id to interval lets remove
// find the node's key. Insert and remove are O(log n) expected; a query is O(log n + k) in practice.

public enum IntervalOverlapTree {
    public final class Tree {
        final class Node {
            let start: Int
            let end: Int
            let id: Int
            let priority: UInt64
            var maxEnd: Int
            var left: Node?
            var right: Node?

            init(start: Int, end: Int, id: Int, priority: UInt64) {
                self.start = start
                self.end = end
                self.id = id
                self.priority = priority
                maxEnd = end
            }

            func update() {
                maxEnd = Swift.max(end, left?.maxEnd ?? Int.min, right?.maxEnd ?? Int.min)
            }
        }

        private var root: Node?
        private var intervals: [Int: (start: Int, end: Int)] = [:]
        private var state: UInt64 = 0x5EED_1234             // SplitMix64, for the priorities

        public init() {}

        public var count: Int { intervals.count }

        private func nextPriority() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }

        /// Splits into (keys before `key`, the rest), or (keys up to and including `key`, the rest).
        private func split(_ node: Node?, _ key: (Int, Int), includingKey: Bool) -> (Node?, Node?) {
            guard let node else { return (nil, nil) }
            let nodeKey = (node.start, node.id)
            let goesLeft = includingKey ? nodeKey <= key : nodeKey < key
            if goesLeft {
                let (middle, right) = split(node.right, key, includingKey: includingKey)
                node.right = middle
                node.update()
                return (node, right)
            }
            let (left, middle) = split(node.left, key, includingKey: includingKey)
            node.left = middle
            node.update()
            return (left, node)
        }

        /// Joins two treaps where every key in `a` is smaller than every key in `b`.
        private func merge(_ a: Node?, _ b: Node?) -> Node? {
            guard let a else { return b }
            guard let b else { return a }
            if a.priority > b.priority {
                a.right = merge(a.right, b)
                a.update()
                return a
            }
            b.left = merge(a, b.left)
            b.update()
            return b
        }

        @discardableResult
        public func insert(start: Int, end: Int, id: Int) -> Bool {
            guard intervals[id] == nil else { return false }
            intervals[id] = (start, end)
            let node = Node(start: start, end: end, id: id, priority: nextPriority())
            let (left, right) = split(root, (start, id), includingKey: false)
            root = merge(merge(left, node), right)
            return true
        }

        @discardableResult
        public func remove(id: Int) -> Bool {
            guard let interval = intervals.removeValue(forKey: id) else { return false }
            let key = (interval.start, id)
            let (left, rest) = split(root, key, includingKey: false)
            let (_, right) = split(rest, key, includingKey: true)
            root = merge(left, right)
            return true
        }

        public func overlapping(start: Int, end: Int) -> [Int] {
            var result: [Int] = []
            func search(_ node: Node?) {
                guard let node, node.maxEnd >= start else { return }
                search(node.left)
                if node.start <= end && start <= node.end {
                    result.append(node.id)
                }
                if node.start <= end {
                    search(node.right)
                }
            }
            search(root)
            return result.sorted()
        }

        public func containing(_ point: Int) -> [Int] {
            overlapping(start: point, end: point)
        }
    }
}
