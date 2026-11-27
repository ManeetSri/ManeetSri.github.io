// Generated from src/dsa/content/lessons/dp-advanced/dpa-bitmask.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Assignment: worker i doing job j costs cost[i][j]. Every worker gets one job, every job one worker.
func cheapestAssignment(_ cost: [[Int]]) -> Int {
    let n = cost.count
    let unreached = Int.max / 2
    var best = [Int](repeating: unreached, count: 1 << n)
    best[0] = 0                                       // nobody assigned, nothing spent
    for mask in 0..<(1 << n) where best[mask] < unreached {
        let worker = mask.nonzeroBitCount             // workers 0..<worker already have the jobs in mask
        if worker == n { continue }
        for job in 0..<n where mask & (1 << job) == 0 {
            let grown = mask | (1 << job)
            best[grown] = min(best[grown], best[mask] + cost[worker][job])
        }
    }
    return best[(1 << n) - 1]
}

// Brute force for checking: try every permutation of jobs
func bruteForce(_ cost: [[Int]]) -> Int {
    let n = cost.count
    var used = [Bool](repeating: false, count: n)
    func assign(_ worker: Int) -> Int {
        if worker == n { return 0 }
        var best = Int.max
        for job in 0..<n where !used[job] {
            used[job] = true
            best = min(best, cost[worker][job] + assign(worker + 1))
            used[job] = false
        }
        return best
    }
    return assign(0)
}

let cost = [
    [9, 2, 7, 8],
    [6, 4, 3, 7],
    [5, 8, 1, 8],
    [7, 6, 9, 4],
]
print(cheapestAssignment(cost), bruteForce(cost))

// 12 workers: 4,096 masks instead of 479,001,600 permutations
let big = (0..<12).map { i in (0..<12).map { j in (i * 37 + j * 91 + i * j * 11) % 50 + 1 } }
print(cheapestAssignment(big))
let eight = (0..<8).map { i in (0..<8).map { j in (i * 37 + j * 91 + i * j * 11) % 50 + 1 } }
print(cheapestAssignment(eight), bruteForce(eight))
