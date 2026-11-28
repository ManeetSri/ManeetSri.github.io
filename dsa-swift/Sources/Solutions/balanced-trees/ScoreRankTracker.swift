// Reference solution: Score rank tracker. A treap whose nodes also store the size of their subtree
// (counting repeated scores, which share one node with a `copies` count). With sizes, one walk down the
// tree answers both questions: going right past a node skips its left subtree and its copies, all of
// them smaller. A new score is inserted with split and merge; a repeat adds one along its search path.
// Priorities come from a seeded generator, so the tree's shape is the same every run, and its expected
// height is O(log n). Every operation is O(log n) expected.

public enum ScoreRankTracker {
    public final class Tracker {
        private final class Node {
            let score: Int
            let priority: UInt64
            var copies = 1
            var size = 1                                     // scores in this subtree, repeats included
            var left: Node?
            var right: Node?

            init(score: Int, priority: UInt64) {
                self.score = score
                self.priority = priority
            }
        }

        private var root: Node?
        private var seed: UInt64 = 2_024
        public private(set) var count = 0

        public init() {}

        public func record(_ score: Int) {
            count += 1
            if contains(score) {
                var current = root                           // one more score below every node on the path
                while let node = current {
                    node.size += 1
                    if score == node.score {
                        node.copies += 1
                        return
                    }
                    current = score < node.score ? node.left : node.right
                }
            }
            let (smaller, rest) = Self.split(root, below: score)
            root = Self.merge(Self.merge(smaller, Node(score: score, priority: nextPriority())), rest)
        }

        public func countAtMost(_ score: Int) -> Int {
            var total = 0
            var current = root
            while let node = current {
                if node.score <= score {
                    total += Self.size(node.left) + node.copies   // all of these are ≤ score
                    current = node.right
                } else {
                    current = node.left
                }
            }
            return total
        }

        public func kthSmallest(_ k: Int) -> Int? {
            guard k >= 1 && k <= count else { return nil }
            var remaining = k
            var current = root
            while let node = current {
                let leftSize = Self.size(node.left)
                if remaining <= leftSize {
                    current = node.left
                } else if remaining <= leftSize + node.copies {
                    return node.score
                } else {
                    remaining -= leftSize + node.copies
                    current = node.right
                }
            }
            return nil
        }

        // MARK: The treap

        private func contains(_ score: Int) -> Bool {
            var current = root
            while let node = current {
                if score == node.score { return true }
                current = score < node.score ? node.left : node.right
            }
            return false
        }

        /// SplitMix64: a seeded generator, so priorities are random-looking but repeatable.
        private func nextPriority() -> UInt64 {
            seed &+= 0x9E37_79B9_7F4A_7C15
            var z = seed
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }

        private static func size(_ node: Node?) -> Int {
            node?.size ?? 0
        }

        private static func update(_ node: Node) {
            node.size = size(node.left) + node.copies + size(node.right)
        }

        /// Splits the treap at `node` into scores below `key` and scores at or above it.
        private static func split(_ node: Node?, below key: Int) -> (Node?, Node?) {
            guard let node else { return (nil, nil) }
            if node.score < key {
                let (smaller, larger) = split(node.right, below: key)
                node.right = smaller
                update(node)
                return (node, larger)
            } else {
                let (smaller, larger) = split(node.left, below: key)
                node.left = larger
                update(node)
                return (smaller, node)
            }
        }

        /// Joins two treaps where every score in `a` is below every score in `b`. The root with the
        /// higher priority stays on top.
        private static func merge(_ a: Node?, _ b: Node?) -> Node? {
            guard let a else { return b }
            guard let b else { return a }
            if a.priority > b.priority {
                a.right = merge(a.right, b)
                update(a)
                return a
            } else {
                b.left = merge(a, b.left)
                update(b)
                return b
            }
        }
    }
}
