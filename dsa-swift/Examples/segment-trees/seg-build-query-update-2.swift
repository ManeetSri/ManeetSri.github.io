// Generated from src/dsa/content/lessons/segment-trees/seg-build-query-update.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Build a sum segment tree recursively, nodes numbered from 1
let items = [5, 3, 7, 9, 6, 4, 1, 2]
var tree = Array(repeating: 0, count: 4 * items.count)

func build(_ node: Int, _ low: Int, _ high: Int) {
    if low == high {
        tree[node] = items[low]                   // a leaf holds one item
        return
    }
    let mid = (low + high) / 2
    build(2 * node, low, mid)                     // left half: low...mid
    build(2 * node + 1, mid + 1, high)            // right half: mid + 1...high
    tree[node] = tree[2 * node] + tree[2 * node + 1]
}

build(1, 0, items.count - 1)
print("root:   ", tree[1])
print("level 1:", tree[2...3])
print("level 2:", tree[4...7])
print("leaves: ", tree[8...15])
