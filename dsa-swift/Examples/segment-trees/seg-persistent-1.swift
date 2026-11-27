// Generated from src/dsa/content/lessons/segment-trees/seg-persistent.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A persistent sum tree: every update makes a new version and keeps every old one
struct PersistentSumTree {
    // Nodes live in three parallel arrays and refer to each other by index. Node 0 is the
    // empty tree: sum 0, and both its children are node 0 itself.
    private var lefts = [0]
    private var rights = [0]
    private var sums = [0]
    private var roots: [Int] = []                 // roots[v] is the root of version v
    let count: Int

    init(_ items: [Int]) {
        count = items.count
        roots.append(build(items, 0, count - 1))  // version 0
    }

    var nodeCount: Int { sums.count }

    private mutating func makeNode(_ left: Int, _ right: Int, _ sum: Int) -> Int {
        lefts.append(left)
        rights.append(right)
        sums.append(sum)
        return sums.count - 1
    }

    private mutating func build(_ items: [Int], _ low: Int, _ high: Int) -> Int {
        if low == high { return makeNode(0, 0, items[low]) }
        let mid = (low + high) / 2
        let left = build(items, low, mid)
        let right = build(items, mid + 1, high)
        return makeNode(left, right, sums[left] + sums[right])
    }

    /// Sets items[index] = value in a new version based on `version`, and returns the new version.
    mutating func update(_ version: Int, _ index: Int, _ value: Int) -> Int {
        roots.append(update(roots[version], 0, count - 1, index, value))
        return roots.count - 1
    }

    // Returns a NEW node for this block. The old node is never changed, so old versions survive.
    private mutating func update(_ node: Int, _ low: Int, _ high: Int, _ index: Int, _ value: Int) -> Int {
        if low == high { return makeNode(0, 0, value) }
        let mid = (low + high) / 2
        var left = lefts[node], right = rights[node]          // share both children...
        if index <= mid {
            left = update(left, low, mid, index, value)          // ...except the one on the path
        } else {
            right = update(right, mid + 1, high, index, value)
        }
        return makeNode(left, right, sums[left] + sums[right])
    }

    /// The sum of items[left...right] as they were in `version`.
    func sum(_ version: Int, _ left: Int, _ right: Int) -> Int {
        query(roots[version], 0, count - 1, left, right)
    }

    private func query(_ node: Int, _ low: Int, _ high: Int, _ left: Int, _ right: Int) -> Int {
        if right < low || high < left { return 0 }
        if left <= low && high <= right { return sums[node] }
        let mid = (low + high) / 2
        return query(lefts[node], low, mid, left, right) + query(rights[node], mid + 1, high, left, right)
    }
}

var tree = PersistentSumTree([5, 3, 7, 9, 6, 4, 1, 2])   // version 0
print("nodes after the build:", tree.nodeCount)
let v1 = tree.update(0, 3, 1)                            // version 1: items[3] = 1
let v2 = tree.update(v1, 0, 10)                          // version 2: version 1 with items[0] = 10
let v3 = tree.update(0, 7, 20)                           // version 3: a branch from version 0
for version in [0, v1, v2, v3] {
    print("version \(version): total \(tree.sum(version, 0, 7)), items 2...6: \(tree.sum(version, 2, 6))")
}
print("nodes after three updates:", tree.nodeCount)
