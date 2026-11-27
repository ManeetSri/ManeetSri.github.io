// Reference solution: A ledger with every version kept. A persistent sum segment tree: nodes live in
// parallel arrays with explicit child links, a deposit copies the root-to-leaf path it changes and shares
// everything else, and each version is just its root. Because balances are never negative, the running
// total grows left to right, so firstReaching walks down by left-child sums. O(log n) per operation,
// O(n + q log n) nodes in total.

public enum VersionedLedgerSums {
    public struct Ledger {
        private var lefts: [Int] = []
        private var rights: [Int] = []
        private var sums: [Int] = []
        private var roots: [Int] = []             // roots[v] is the root of version v
        private let count: Int

        public init(_ balances: [Int]) {
            count = balances.count
            lefts.reserveCapacity(2 * count)
            rights.reserveCapacity(2 * count)
            sums.reserveCapacity(2 * count)
            roots.append(build(balances, 0, count - 1))
        }

        public var versionCount: Int {
            roots.count
        }

        private mutating func makeNode(_ left: Int, _ right: Int, _ sum: Int) -> Int {
            lefts.append(left)
            rights.append(right)
            sums.append(sum)
            return sums.count - 1
        }

        private mutating func build(_ balances: [Int], _ low: Int, _ high: Int) -> Int {
            if low == high { return makeNode(-1, -1, balances[low]) }
            let mid = (low + high) / 2
            let left = build(balances, low, mid)
            let right = build(balances, mid + 1, high)
            return makeNode(left, right, sums[left] + sums[right])
        }

        public mutating func deposit(_ amount: Int, into index: Int, basedOn version: Int) -> Int {
            roots.append(added(amount, at: index, to: roots[version], 0, count - 1))
            return roots.count - 1
        }

        // Returns a NEW node for this block, sharing the child that isn't on the path
        private mutating func added(_ amount: Int, at index: Int, to node: Int, _ low: Int, _ high: Int) -> Int {
            if low == high { return makeNode(-1, -1, sums[node] + amount) }
            let mid = (low + high) / 2
            var left = lefts[node]
            var right = rights[node]
            if index <= mid {
                left = added(amount, at: index, to: left, low, mid)
            } else {
                right = added(amount, at: index, to: right, mid + 1, high)
            }
            return makeNode(left, right, sums[left] + sums[right])
        }

        public func total(from left: Int, through right: Int, in version: Int) -> Int {
            sum(roots[version], 0, count - 1, left, right)
        }

        private func sum(_ node: Int, _ low: Int, _ high: Int, _ left: Int, _ right: Int) -> Int {
            if right < low || high < left { return 0 }
            if left <= low && high <= right { return sums[node] }
            let mid = (low + high) / 2
            return sum(lefts[node], low, mid, left, right) + sum(rights[node], mid + 1, high, left, right)
        }

        public func firstReaching(_ target: Int, in version: Int) -> Int? {
            var node = roots[version]
            guard sums[node] >= target else { return nil }
            var low = 0
            var high = count - 1
            var target = target
            while low < high {
                let mid = (low + high) / 2
                let leftSum = sums[lefts[node]]
                if leftSum >= target {            // the left half already reaches it
                    node = lefts[node]
                    high = mid
                } else {
                    target -= leftSum
                    node = rights[node]
                    low = mid + 1
                }
            }
            return low
        }
    }
}
