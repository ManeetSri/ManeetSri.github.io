// Generated from src/dsa/content/lessons/segment-trees/seg-vs-others.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Walking down a maximum tree: the first index whose value is at least x, in O(log n)
let items = [3, 1, 4, 1, 5, 9, 2, 6]
var tree = Array(repeating: Int.min, count: 4 * items.count)

func build(_ node: Int, _ low: Int, _ high: Int) {
    if low == high {
        tree[node] = items[low]
        return
    }
    let mid = (low + high) / 2
    build(2 * node, low, mid)
    build(2 * node + 1, mid + 1, high)
    tree[node] = max(tree[2 * node], tree[2 * node + 1])
}

func descend(_ x: Int, _ node: Int, _ low: Int, _ high: Int) -> Int? {
    if tree[node] < x { return nil }              // nothing in this block is big enough
    if low == high { return low }
    let mid = (low + high) / 2
    if tree[2 * node] >= x {                      // the left half has one, and it comes first
        return descend(x, 2 * node, low, mid)
    }
    return descend(x, 2 * node + 1, mid + 1, high)
}

func firstAtLeast(_ x: Int) -> Int? {
    descend(x, 1, 0, items.count - 1)
}

build(1, 0, items.count - 1)
print(firstAtLeast(4) ?? -1, firstAtLeast(6) ?? -1, firstAtLeast(10) ?? -1)
