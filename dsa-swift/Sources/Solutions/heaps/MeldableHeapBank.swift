// Reference solution: A bank of mergeable heaps. Each heap is a pairing heap: one heap-ordered tree whose
// nodes can have any number of children, stored for every heap together in value, firstChild and
// nextSibling arrays. Melding links the larger root under the smaller one, O(1); push is a meld with a
// single node. popMin melds the root's children in pairs left to right, then right to left, which is
// O(log n) amortised. No class nodes, so even a chain-shaped tree is released safely.

public enum MeldableHeapBank {
    public struct HeapBank {
        private var value: [Int] = []                    // node storage, shared by every heap
        private var firstChild: [Int] = []
        private var nextSibling: [Int] = []
        private var root: [Int]                          // each heap's root node, or -1
        private var sizes: [Int]

        public init(count: Int) {
            root = Array(repeating: -1, count: count)
            sizes = Array(repeating: 0, count: count)
        }

        public func size(of heap: Int) -> Int { sizes[heap] }

        public func min(of heap: Int) -> Int? {
            root[heap] < 0 ? nil : value[root[heap]]
        }

        public mutating func push(_ newValue: Int, onto heap: Int) {
            value.append(newValue)
            firstChild.append(-1)
            nextSibling.append(-1)
            root[heap] = link(root[heap], value.count - 1)
            sizes[heap] += 1
        }

        public mutating func meld(_ source: Int, into target: Int) {
            guard source != target else { return }
            root[target] = link(root[target], root[source])
            sizes[target] += sizes[source]
            root[source] = -1
            sizes[source] = 0
        }

        public mutating func popMin(from heap: Int) -> Int? {
            let top = root[heap]
            guard top >= 0 else { return nil }
            var children: [Int] = []                     // detach the root's children
            var child = firstChild[top]
            while child >= 0 {
                let next = nextSibling[child]
                nextSibling[child] = -1
                children.append(child)
                child = next
            }
            var pairs: [Int] = []                        // pass 1: meld in pairs, left to right
            var i = 0
            while i < children.count {
                pairs.append(i + 1 < children.count ? link(children[i], children[i + 1]) : children[i])
                i += 2
            }
            var combined = -1                            // pass 2: meld the pairs, right to left
            for tree in pairs.reversed() {
                combined = link(tree, combined)
            }
            root[heap] = combined
            sizes[heap] -= 1
            return value[top]
        }

        /// Melds two trees given by their roots (-1 for empty), returning the new root.
        private mutating func link(_ a: Int, _ b: Int) -> Int {
            if a < 0 { return b }
            if b < 0 { return a }
            let (top, other) = value[b] < value[a] ? (b, a) : (a, b)
            nextSibling[other] = firstChild[top]         // other becomes top's newest child
            firstChild[top] = other
            return top
        }
    }
}
