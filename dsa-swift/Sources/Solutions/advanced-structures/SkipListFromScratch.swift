// Reference solution: a skip list of distinct Ints. Each node keeps one forward link per level it's
// on; a head sentinel as tall as `maxLevel` starts every level. Searching moves right while the next
// value is smaller and drops a level otherwise, recording the last node before the target on each
// level. Insert splices a new node in after those predecessors on each of its levels; remove makes
// them skip it. Heights come from the injected coin, so everything is O(log n) expected for any input.

public enum SkipListFromScratch {
    public final class SkipSet {
        final class Node {
            let value: Int
            var next: [Node?]

            init(value: Int, height: Int) {
                self.value = value
                next = Array(repeating: nil, count: height)
            }
        }

        public let maxLevel: Int
        private let coinFlip: () -> Bool
        private let head: Node
        private var height = 1                  // levels in use, at least 1
        public private(set) var count = 0

        public init(maxLevel: Int = 16, coinFlip: @escaping () -> Bool) {
            self.maxLevel = max(1, maxLevel)
            self.coinFlip = coinFlip
            head = Node(value: Int.min, height: self.maxLevel)
        }

        // Freeing node 1 would free node 2 from inside node 1's deinit, and so on down the list: one
        // nested call per node, which overflows a test thread's stack. Unlink level 1 with a loop.
        deinit {
            var current = head.next[0]
            for level in head.next.indices {
                head.next[level] = nil
            }
            while let node = current {
                current = node.next[0]
                node.next.removeAll()
            }
        }

        /// The last node before `value` on every level in use.
        private func predecessors(of value: Int) -> [Node] {
            var result = Array(repeating: head, count: height)
            var current = head
            for level in stride(from: height - 1, through: 0, by: -1) {
                while let next = current.next[level], next.value < value {
                    current = next
                }
                result[level] = current
            }
            return result
        }

        public func contains(_ value: Int) -> Bool {
            predecessors(of: value)[0].next[0]?.value == value
        }

        public func ceiling(_ value: Int) -> Int? {
            predecessors(of: value)[0].next[0]?.value
        }

        @discardableResult
        public func insert(_ value: Int) -> Bool {
            var before = predecessors(of: value)
            if before[0].next[0]?.value == value { return false }
            var nodeHeight = 1
            while nodeHeight < maxLevel && coinFlip() {
                nodeHeight += 1
            }
            while before.count < nodeHeight {
                before.append(head)                 // new levels start from the head
            }
            height = max(height, nodeHeight)
            let node = Node(value: value, height: nodeHeight)
            for level in 0..<nodeHeight {
                node.next[level] = before[level].next[level]
                before[level].next[level] = node
            }
            count += 1
            return true
        }

        @discardableResult
        public func remove(_ value: Int) -> Bool {
            let before = predecessors(of: value)
            guard let node = before[0].next[0], node.value == value else { return false }
            for level in 0..<node.next.count {
                before[level].next[level] = node.next[level]
            }
            while height > 1 && head.next[height - 1] == nil {
                height -= 1
            }
            count -= 1
            return true
        }

        public var elements: [Int] {
            var result: [Int] = []
            result.reserveCapacity(count)
            var current = head.next[0]
            while let node = current {
                result.append(node.value)
                current = node.next[0]
            }
            return result
        }

        public var levelSizes: [Int] {
            var sizes: [Int] = []
            for level in 0..<height {
                var size = 0
                var current = head.next[level]
                while let node = current {
                    size += 1
                    current = node.next[level]
                }
                if size == 0 { break }
                sizes.append(size)
            }
            return sizes
        }
    }
}
