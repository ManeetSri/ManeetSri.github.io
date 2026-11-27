// Generated from src/dsa/content/lessons/segment-trees/seg-build-query-update.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Count the nodes a query visits, over many ranges of a 100,000-item tree
let n = 100_000
var visited = 0
func query(_ node: Int, _ low: Int, _ high: Int, _ left: Int, _ right: Int) {
    visited += 1
    if right < low || high < left { return }
    if left <= low && high <= right { return }
    let mid = (low + high) / 2
    query(2 * node, low, mid, left, right)
    query(2 * node + 1, mid + 1, high, left, right)
}

var state: UInt64 = 7                             // a fixed seed, so every run is the same
func nextIndex() -> Int {
    state = state &* 6364136223846793005 &+ 1442695040888963407
    return Int((state >> 33) % UInt64(n))
}

var most = 0
var total = 0
for _ in 0..<10_000 {
    let a = nextIndex(), b = nextIndex()
    visited = 0
    query(1, 0, n - 1, min(a, b), max(a, b))
    most = max(most, visited)
    total += visited
}
print("most nodes visited by one query:", most)
print("average:", total / 10_000)
