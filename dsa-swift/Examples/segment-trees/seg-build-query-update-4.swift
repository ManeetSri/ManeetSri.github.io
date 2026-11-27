// Generated from src/dsa/content/lessons/segment-trees/seg-build-query-update.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A sum segment tree: recursive, nodes numbered from 1, closed ranges
struct SumTree {
    private var tree: [Int]
    private let count: Int

    init(_ items: [Int]) {
        count = items.count
        tree = Array(repeating: 0, count: max(1, 4 * items.count))
        if count > 0 { build(items, 1, 0, count - 1) }
    }

    /// The sum of items[left...right].
    func sum(_ left: Int, _ right: Int) -> Int {
        query(1, 0, count - 1, left, right)
    }

    mutating func set(_ index: Int, to value: Int) {
        update(1, 0, count - 1, index, value)
    }

    private mutating func build(_ items: [Int], _ node: Int, _ low: Int, _ high: Int) {
        if low == high {
            tree[node] = items[low]
            return
        }
        let mid = (low + high) / 2
        build(items, 2 * node, low, mid)
        build(items, 2 * node + 1, mid + 1, high)
        tree[node] = tree[2 * node] + tree[2 * node + 1]
    }

    private func query(_ node: Int, _ low: Int, _ high: Int, _ left: Int, _ right: Int) -> Int {
        if right < low || high < left { return 0 }
        if left <= low && high <= right { return tree[node] }
        let mid = (low + high) / 2
        return query(2 * node, low, mid, left, right) + query(2 * node + 1, mid + 1, high, left, right)
    }

    private mutating func update(_ node: Int, _ low: Int, _ high: Int, _ index: Int, _ value: Int) {
        if low == high {
            tree[node] = value
            return
        }
        let mid = (low + high) / 2
        if index <= mid {
            update(2 * node, low, mid, index, value)
        } else {
            update(2 * node + 1, mid + 1, high, index, value)
        }
        tree[node] = tree[2 * node] + tree[2 * node + 1]
    }
}

var sums = SumTree([5, 3, 7, 9, 6, 4, 1, 2])
print(sums.sum(2, 6))
sums.set(3, to: 1)
print(sums.sum(2, 6), sums.sum(0, 7), sums.sum(4, 4))

// Check every range against plain addition, after each of 1,000 updates on 11 items
var items = [4, -2, 8, 0, 3, 3, 9, -5, 1, 6, 2]
var checked = SumTree(items)
var mismatches = 0
for step in 0..<1_000 {
    let index = (step * 7) % items.count
    let value = (step * 13) % 21 - 10
    items[index] = value
    checked.set(index, to: value)
    for left in 0..<items.count {
        for right in left..<items.count where checked.sum(left, right) != items[left...right].reduce(0, +) {
            mismatches += 1
        }
    }
}
print("mismatches:", mismatches)
