// Generated from src/dsa/content/lessons/segment-trees/seg-merge-sort-tree.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A merge-sort tree: every node keeps its block's values in sorted order
struct MergeSortTree {
    private var sorted: [[Int]]
    private let count: Int

    init(_ items: [Int]) {
        count = items.count
        sorted = Array(repeating: [], count: 4 * items.count)
        build(items, 1, 0, count - 1)
    }

    private mutating func build(_ items: [Int], _ node: Int, _ low: Int, _ high: Int) {
        if low == high {
            sorted[node] = [items[low]]
            return
        }
        let mid = (low + high) / 2
        build(items, 2 * node, low, mid)
        build(items, 2 * node + 1, mid + 1, high)
        sorted[node] = merged(sorted[2 * node], sorted[2 * node + 1])
    }

    // The merge step of merge sort: two sorted arrays into one
    private func merged(_ a: [Int], _ b: [Int]) -> [Int] {
        var result: [Int] = []
        result.reserveCapacity(a.count + b.count)
        var i = 0, j = 0
        while i < a.count && j < b.count {
            if a[i] <= b[j] { result.append(a[i]); i += 1 } else { result.append(b[j]); j += 1 }
        }
        result.append(contentsOf: a[i...])
        result.append(contentsOf: b[j...])
        return result
    }

    /// How many of items[left...right] are at most x.
    func countAtMost(_ x: Int, _ left: Int, _ right: Int) -> Int {
        count(x, left, right, 1, 0, count - 1)
    }

    private func count(_ x: Int, _ left: Int, _ right: Int, _ node: Int, _ low: Int, _ high: Int) -> Int {
        if right < low || high < left { return 0 }
        if left <= low && high <= right { return upperBound(sorted[node], x) }   // a whole block
        let mid = (low + high) / 2
        return count(x, left, right, 2 * node, low, mid) + count(x, left, right, 2 * node + 1, mid + 1, high)
    }

    // The number of values in a sorted array that are at most x: the first index holding more than x
    private func upperBound(_ values: [Int], _ x: Int) -> Int {
        var low = 0, high = values.count
        while low < high {
            let mid = (low + high) / 2
            if values[mid] <= x { low = mid + 1 } else { high = mid }
        }
        return low
    }

    /// The kth smallest (counting from 1) of items[left...right]: binary search over every value
    /// for the first one with at least k values at most it in the range.
    func kthSmallest(_ k: Int, _ left: Int, _ right: Int) -> Int {
        let all = sorted[1]                       // the root holds every value, sorted
        var low = 0, high = all.count - 1
        while low < high {
            let mid = (low + high) / 2
            if countAtMost(all[mid], left, right) >= k { high = mid } else { low = mid + 1 }
        }
        return all[low]
    }

    /// The nodes of one level, for printing.
    func level(_ depth: Int) -> [[Int]] {
        Array(sorted[(1 << depth)..<(2 << depth)])
    }
}

let items = [5, 1, 7, 3, 8, 2, 6, 4]
let tree = MergeSortTree(items)
for depth in 0...3 {
    print(tree.level(depth))
}
print(tree.countAtMost(4, 1, 6))        // 1, 7, 3, 8, 2, 6: three of them are at most 4
print(tree.countAtMost(0, 0, 7), tree.countAtMost(9, 0, 7), tree.countAtMost(5, 2, 2))
print(tree.kthSmallest(1, 1, 6), tree.kthSmallest(3, 1, 6), tree.kthSmallest(6, 1, 6))

// Check every range, every x and every k against sorting the range
var mismatches = 0
for left in 0..<items.count {
    for right in left..<items.count {
        let range = items[left...right].sorted()
        for x in 0...9 where tree.countAtMost(x, left, right) != range.filter({ $0 <= x }).count {
            mismatches += 1
        }
        for k in 1...range.count where tree.kthSmallest(k, left, right) != range[k - 1] {
            mismatches += 1
        }
    }
}
print("mismatches:", mismatches)
