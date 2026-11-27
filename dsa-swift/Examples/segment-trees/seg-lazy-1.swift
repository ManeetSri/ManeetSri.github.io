// Generated from src/dsa/content/lessons/segment-trees/seg-lazy.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Lazy propagation: add to a range and sum a range, both in O(log n)
struct RangeAddTree {
    private var sums: [Int]
    private var pending: [Int]                    // added to the whole node, not yet to its children
    private let count: Int

    init(_ items: [Int]) {
        count = items.count
        sums = Array(repeating: 0, count: 4 * items.count)
        pending = Array(repeating: 0, count: 4 * items.count)
        build(items, 1, 0, count - 1)
    }

    /// Adds delta to every item in left...right.
    mutating func add(_ delta: Int, _ left: Int, _ right: Int) {
        add(delta, left, right, 1, 0, count - 1)
    }

    /// The sum of items[left...right].
    mutating func sum(_ left: Int, _ right: Int) -> Int {
        sum(left, right, 1, 0, count - 1)
    }

    private mutating func build(_ items: [Int], _ node: Int, _ low: Int, _ high: Int) {
        if low == high {
            sums[node] = items[low]
            return
        }
        let mid = (low + high) / 2
        build(items, 2 * node, low, mid)
        build(items, 2 * node + 1, mid + 1, high)
        sums[node] = sums[2 * node] + sums[2 * node + 1]
    }

    // Adds delta to every item under node (which covers low...high), and notes it for the children
    private mutating func apply(_ delta: Int, _ node: Int, _ low: Int, _ high: Int) {
        sums[node] += delta * (high - low + 1)
        pending[node] += delta
    }

    // Hands node's pending addition to its two children, before anything goes below node
    private mutating func push(_ node: Int, _ low: Int, _ mid: Int, _ high: Int) {
        if pending[node] == 0 { return }
        apply(pending[node], 2 * node, low, mid)
        apply(pending[node], 2 * node + 1, mid + 1, high)
        pending[node] = 0
    }

    private mutating func add(_ delta: Int, _ left: Int, _ right: Int, _ node: Int, _ low: Int, _ high: Int) {
        if right < low || high < left { return }
        if left <= low && high <= right {
            apply(delta, node, low, high)         // a whole block: stop here
            return
        }
        let mid = (low + high) / 2
        push(node, low, mid, high)                // the children must be up to date first
        add(delta, left, right, 2 * node, low, mid)
        add(delta, left, right, 2 * node + 1, mid + 1, high)
        sums[node] = sums[2 * node] + sums[2 * node + 1]
    }

    private mutating func sum(_ left: Int, _ right: Int, _ node: Int, _ low: Int, _ high: Int) -> Int {
        if right < low || high < left { return 0 }
        if left <= low && high <= right { return sums[node] }
        let mid = (low + high) / 2
        push(node, low, mid, high)
        return sum(left, right, 2 * node, low, mid) + sum(left, right, 2 * node + 1, mid + 1, high)
    }

    /// Prints each level as "sum(+pending)", leaves without tags. Lines up when count is a power of two.
    func show() {
        var first = 1
        while first < 2 * count {
            let isLeafLevel = first >= count
            let level = (first..<(2 * first)).map { node in
                pending[node] == 0 || isLeafLevel ? "\(sums[node])" : "\(sums[node])(+\(pending[node]))"
            }
            print("  " + level.joined(separator: " "))
            first *= 2
        }
    }
}

var tree = RangeAddTree(Array(repeating: 0, count: 8))
print("add 3 to items 2...5:")
tree.add(3, 2, 5)
tree.show()
print("sum of items 3...3:", tree.sum(3, 3))
tree.show()
print("add 1 to everything:")
tree.add(1, 0, 7)
tree.show()
print("sum of items 4...7:", tree.sum(4, 7))
tree.show()
