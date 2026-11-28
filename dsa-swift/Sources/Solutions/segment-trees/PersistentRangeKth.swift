// Reference solution: Kth cheapest trade in a range. Compress prices to ranks, then keep one persistent
// count tree per prefix: version i counts the ranks of prices[0..<i], and differs from version i − 1 by
// one copied path. Counts for left...right are version right + 1 minus version left, so walk both trees
// down together, steering by the left-child difference. O(n log n) build and memory, O(log n) per query.

public enum PersistentRangeKth {
    public struct Finder {
        private var lefts = [0]                   // node 0 is the empty tree: count 0, children itself
        private var rights = [0]
        private var counts = [0]
        private var roots = [0]                   // roots[i] counts the ranks among prices[0..<i]
        private let values: [Int]                 // the distinct prices, sorted: rank r is values[r]

        public init(_ prices: [Int]) {
            values = Array(Set(prices)).sorted()
            var rankOf: [Int: Int] = [:]
            for (rank, value) in values.enumerated() {
                rankOf[value] = rank
            }
            let perVersion = values.count.bitWidth - values.count.leadingZeroBitCount + 1
            lefts.reserveCapacity(prices.count * perVersion + 1)
            rights.reserveCapacity(prices.count * perVersion + 1)
            counts.reserveCapacity(prices.count * perVersion + 1)
            for price in prices {
                roots.append(insert(roots[roots.count - 1], 0, values.count - 1, rankOf[price]!))
            }
        }

        // Returns a new node: a copy of `node` with one more price counted at `rank`. Never edits a node.
        private mutating func insert(_ node: Int, _ low: Int, _ high: Int, _ rank: Int) -> Int {
            var left = lefts[node]
            var right = rights[node]
            if low < high {
                let mid = (low + high) / 2
                if rank <= mid {
                    left = insert(left, low, mid, rank)
                } else {
                    right = insert(right, mid + 1, high, rank)
                }
            }
            lefts.append(left)
            rights.append(right)
            counts.append(counts[node] + 1)
            return counts.count - 1
        }

        public func kthSmallest(_ k: Int, from left: Int, through right: Int) -> Int {
            var newer = roots[right + 1]
            var older = roots[left]
            var low = 0
            var high = values.count - 1
            var k = k
            while low < high {
                let mid = (low + high) / 2
                let inLeftHalf = counts[lefts[newer]] - counts[lefts[older]]
                if k <= inLeftHalf {              // the answer's rank is in low...mid
                    newer = lefts[newer]
                    older = lefts[older]
                    high = mid
                } else {                          // skip the cheaper prices and go right
                    k -= inLeftHalf
                    newer = rights[newer]
                    older = rights[older]
                    low = mid + 1
                }
            }
            return values[low]
        }
    }
}
