// Reference solution: Longest dry spell. A segment tree whose nodes summarise a block of days with
// four numbers: its length, the dry run touching its left end, the dry run touching its right end, and
// its longest dry run anywhere. Two neighbouring blocks join in O(1): the longest run is in the left,
// in the right, or crosses the middle (the left's suffix plus the right's prefix), and a block that's
// dry all the way through extends its neighbour's run. The all-zero summary is the identity.
// O(n) to build, O(log n) per change and per question, O(n) space.

public enum LongestDrySpell {
    /// A block of days, summarised.
    private struct Block {
        var length: Int
        var prefix: Int                         // dry days running from the block's first day
        var suffix: Int                         // dry days running up to its last day
        var best: Int                           // the longest dry run inside it

        static let empty = Block(length: 0, prefix: 0, suffix: 0, best: 0)

        static func day(rainy: Bool) -> Block {
            rainy ? Block(length: 1, prefix: 0, suffix: 0, best: 0) : Block(length: 1, prefix: 1, suffix: 1, best: 1)
        }

        static func join(_ a: Block, _ b: Block) -> Block {
            Block(length: a.length + b.length,
                  prefix: a.prefix == a.length ? a.length + b.prefix : a.prefix,
                  suffix: b.suffix == b.length ? b.length + a.suffix : b.suffix,
                  best: max(a.best, b.best, a.suffix + b.prefix))
        }
    }

    public struct Log {
        private var tree: [Block]               // bottom-up layout: days are the leaves tree[n..<2n]
        private let count: Int

        public init(_ rainy: [Bool]) {
            count = rainy.count
            tree = Array(repeating: .empty, count: rainy.count) + rainy.map { Block.day(rainy: $0) }
            for node in stride(from: count - 1, through: 1, by: -1) {
                tree[node] = Block.join(tree[2 * node], tree[2 * node + 1])
            }
        }

        public mutating func setRainy(_ rainy: Bool, on day: Int) {
            var node = day + count
            tree[node] = Block.day(rainy: rainy)
            while node > 1 {
                node /= 2
                tree[node] = Block.join(tree[2 * node], tree[2 * node + 1])
            }
        }

        public func longestDryRun(from start: Int, through end: Int) -> Int {
            // Joining isn't commutative, so keep the pieces from each end in order
            var left = start + count, right = end + count + 1
            var fromLeft = Block.empty, fromRight = Block.empty
            while left < right {
                if left % 2 == 1 {
                    fromLeft = Block.join(fromLeft, tree[left])
                    left += 1
                }
                if right % 2 == 1 {
                    right -= 1
                    fromRight = Block.join(tree[right], fromRight)
                }
                left /= 2
                right /= 2
            }
            return Block.join(fromLeft, fromRight).best
        }
    }
}
