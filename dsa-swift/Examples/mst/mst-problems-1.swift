// Generated from src/dsa/content/lessons/mst/mst-problems.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The cheapest way to wire every point together, where a wire costs the Manhattan distance.
/// O(n²) Prim that computes each distance when it needs it: no edge list at all.
func connectAll(_ points: [(x: Int, y: Int)]) -> Int {
    let n = points.count
    var inTree = Array(repeating: false, count: n)
    var cheapest = Array(repeating: Int.max, count: n)
    cheapest[0] = 0
    var total = 0
    for _ in 0..<n {
        var next = -1
        for v in 0..<n where !inTree[v] && (next == -1 || cheapest[v] < cheapest[next]) {
            next = v
        }
        inTree[next] = true
        total += cheapest[next]
        for v in 0..<n where !inTree[v] {
            let distance = abs(points[v].x - points[next].x) + abs(points[v].y - points[next].y)
            cheapest[v] = min(cheapest[v], distance)
        }
    }
    return total
}

let lamps = [(x: 1, y: 1), (x: 4, y: 1), (x: 4, y: 5), (x: 0, y: 6), (x: 8, y: 3)]
print("cheapest wiring:", connectAll(lamps))
for n in [5, 2_000] {
    print("\(n) points: Kruskal would build \(n * (n - 1) / 2) edges; this keeps \(n) numbers")
}
