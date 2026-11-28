// Generated from src/dsa/content/lessons/dp-advanced/dpa-bitmask.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Shortest route through every checkpoint once, starting and ending anywhere (no return trip)
func shortestRoute(_ distance: [[Int]]) -> Int {
    let n = distance.count
    let full = 1 << n
    let unreached = Int.max / 2
    // best[mask * n + last]: shortest path visiting exactly the checkpoints in mask, ending at last
    var best = [Int](repeating: unreached, count: full * n)
    for v in 0..<n {
        best[(1 << v) * n + v] = 0                  // a path can start at any checkpoint
    }
    for mask in 1..<full {
        for last in 0..<n where mask & (1 << last) != 0 {
            let here = best[mask * n + last]
            if here == unreached { continue }
            for next in 0..<n where mask & (1 << next) == 0 {
                let grown = (mask | (1 << next)) * n + next
                best[grown] = min(best[grown], here + distance[last][next])
            }
        }
    }
    return (0..<n).map { best[(full - 1) * n + $0] }.min()!
}

let distance = [
    [0, 12, 10, 19, 8],
    [12, 0, 3, 7, 2],
    [10, 3, 0, 6, 20],
    [19, 7, 6, 0, 4],
    [8, 2, 20, 4, 0],
]
print("open route:", shortestRoute(distance))
