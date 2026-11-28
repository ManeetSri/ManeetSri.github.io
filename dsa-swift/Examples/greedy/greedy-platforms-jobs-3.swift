// Generated from src/dsa/content/lessons/greedy/greedy-platforms-jobs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The most profit from one-slot jobs with deadlines, using a union-find of free slots
func bestProfit(_ jobs: [(deadline: Int, profit: Int)]) -> Int {
    let n = jobs.count
    var parent = Array(0...n)              // a free slot points at itself; 0 means "no slot"
    // The latest free slot at or before `slot`, re-pointing the path at it as we go
    func latestFree(_ slot: Int) -> Int {
        var root = slot
        while parent[root] != root { root = parent[root] }
        var current = slot
        while parent[current] != root {
            let next = parent[current]
            parent[current] = root
            current = next
        }
        return root
    }
    var total = 0
    for job in jobs.sorted(by: { $0.profit > $1.profit }) {
        let slot = latestFree(min(job.deadline, n))    // n jobs never need more than n slots
        if slot > 0 {
            parent[slot] = slot - 1                    // taken: look one slot earlier next time
            total += job.profit
        }
        print("deadline \(job.deadline), profit \(job.profit): slot \(slot), parent \(parent)")
    }
    return total
}

print(bestProfit([(2, 40), (1, 25), (3, 30), (1, 35), (3, 10), (2, 20)]))
print(bestProfit([(1_000_000_000, 5), (1, 7), (1, 3)]))
