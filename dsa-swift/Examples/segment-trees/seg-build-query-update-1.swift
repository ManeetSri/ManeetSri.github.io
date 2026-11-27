// Generated from src/dsa/content/lessons/segment-trees/seg-build-query-update.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The largest node index the recursive layout uses, for n items
func largestIndex(_ node: Int, _ low: Int, _ high: Int) -> Int {
    if low == high { return node }
    let mid = (low + high) / 2
    return max(largestIndex(2 * node, low, mid), largestIndex(2 * node + 1, mid + 1, high))
}
for n in [1, 5, 6, 8, 9, 17, 100, 1_000] {
    print("n = \(n): largest index \(largestIndex(1, 0, n - 1)), 2n = \(2 * n), 4n = \(4 * n)")
}
