// Generated from src/dsa/content/lessons/recursion/rec-recursion-trees.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var calls = 0
var deepest = 0

func sum(_ items: [Int], _ low: Int, _ high: Int, depth: Int = 1) -> Int {
    calls += 1
    deepest = max(deepest, depth)
    if low == high {
        return items[low]
    }
    let mid = (low + high) / 2
    return sum(items, low, mid, depth: depth + 1) + sum(items, mid + 1, high, depth: depth + 1)
}

for n in [8, 1_000, 1_000_000] {
    calls = 0
    deepest = 0
    let items = Array(1...n)
    let total = sum(items, 0, n - 1)
    print("n = \(n): total \(total), \(calls) calls, \(deepest) deep")
}
