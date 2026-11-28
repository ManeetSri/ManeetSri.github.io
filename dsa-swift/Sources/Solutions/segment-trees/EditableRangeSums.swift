// Reference solution: Range sums with edits. A sum segment tree in the bottom-up layout: the values
// are the leaves in tree[n..<2n], and each internal node k holds tree[2k] + tree[2k + 1]. An edit
// rewrites one leaf and the nodes above it; a sum climbs from both ends of the range at once.
// O(n) to build, O(log n) per edit and per sum, O(n) space.

public enum EditableRangeSums {
    public struct Table {
        private var tree: [Int]
        private let count: Int

        public init(_ values: [Int]) {
            count = values.count
            tree = Array(repeating: 0, count: values.count) + values
            for node in stride(from: count - 1, through: 1, by: -1) {
                tree[node] = tree[2 * node] + tree[2 * node + 1]
            }
        }

        public mutating func update(at index: Int, to value: Int) {
            var node = index + count
            tree[node] = value
            while node > 1 {
                node /= 2
                tree[node] = tree[2 * node] + tree[2 * node + 1]
            }
        }

        public func sum(from start: Int, through end: Int) -> Int {
            var left = start + count
            var right = end + count + 1                 // half-open inside: start..<end + 1
            var total = 0
            while left < right {
                if left % 2 == 1 {                      // a right child: take it alone
                    total += tree[left]
                    left += 1
                }
                if right % 2 == 1 {                     // right - 1 is a left child: take it alone
                    right -= 1
                    total += tree[right]
                }
                left /= 2
                right /= 2
            }
            return total
        }
    }
}
