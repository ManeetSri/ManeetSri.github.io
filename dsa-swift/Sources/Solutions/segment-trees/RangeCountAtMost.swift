// Reference solution: Values at most x in a range. A merge-sort tree: every node of a segment tree
// keeps its block's values sorted, each node's array being its children's arrays merged, exactly as in
// merge sort. A query splits left...right into O(log n) whole blocks, and in each block an upper-bound
// binary search counts the values at most x. O(n log n) to build, O(log² n) per query,
// O(n log n) space.

public enum RangeCountAtMost {
    public static func answer(_ values: [Int], queries: [[Int]]) -> [Int] {
        guard !values.isEmpty else { return queries.map { _ in 0 } }
        let tree = MergeSortTree(values)
        return queries.map { tree.countAtMost($0[2], $0[0], $0[1]) }
    }

    private struct MergeSortTree {
        private var sorted: [[Int]]
        private let count: Int

        init(_ values: [Int]) {
            count = values.count
            sorted = Array(repeating: [], count: 4 * values.count)
            build(values, 1, 0, count - 1)
        }

        private mutating func build(_ values: [Int], _ node: Int, _ low: Int, _ high: Int) {
            if low == high {
                sorted[node] = [values[low]]
                return
            }
            let mid = (low + high) / 2
            build(values, 2 * node, low, mid)
            build(values, 2 * node + 1, mid + 1, high)
            // Merge the two sorted children in one pass
            let a = sorted[2 * node], b = sorted[2 * node + 1]
            var merged: [Int] = []
            merged.reserveCapacity(a.count + b.count)
            var i = 0, j = 0
            while i < a.count && j < b.count {
                if a[i] <= b[j] {
                    merged.append(a[i])
                    i += 1
                } else {
                    merged.append(b[j])
                    j += 1
                }
            }
            merged.append(contentsOf: a[i...])
            merged.append(contentsOf: b[j...])
            sorted[node] = merged
        }

        func countAtMost(_ x: Int, _ left: Int, _ right: Int) -> Int {
            count(x, left, right, 1, 0, count - 1)
        }

        private func count(_ x: Int, _ left: Int, _ right: Int, _ node: Int, _ low: Int, _ high: Int) -> Int {
            if right < low || high < left { return 0 }
            if left <= low && high <= right { return upperBound(sorted[node], x) }
            let mid = (low + high) / 2
            return count(x, left, right, 2 * node, low, mid) + count(x, left, right, 2 * node + 1, mid + 1, high)
        }

        /// How many values in a sorted array are at most x: the index of the first one greater than x.
        private func upperBound(_ values: [Int], _ x: Int) -> Int {
            var low = 0, high = values.count
            while low < high {
                let mid = (low + high) / 2
                if values[mid] <= x { low = mid + 1 } else { high = mid }
            }
            return low
        }
    }
}
