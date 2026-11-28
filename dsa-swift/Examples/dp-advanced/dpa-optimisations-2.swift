// Generated from src/dsa/content/lessons/dp-advanced/dpa-optimisations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Split jobs (in order) into batches. A batch whose pages add up to s costs s² + setup.
// best[i] = cheapest way to print the first i jobs = min over j < i of best[j] + (S[i] - S[j])² + setup
func batchCostSlow(_ pages: [Int], setup: Int) -> Int {
    let n = pages.count
    var prefix = [0]
    for p in pages { prefix.append(prefix.last! + p) }
    var best = [Int](repeating: Int.max, count: n + 1)
    best[0] = 0
    for i in 1...n {
        for j in 0..<i {
            let s = prefix[i] - prefix[j]
            best[i] = min(best[i], best[j] + s * s + setup)
        }
    }
    return best[n]
}

// The same DP with the convex hull trick. Each j is a line: slope -2·S[j], intercept best[j] + S[j]²,
// and best[i] = (the lowest line at x = S[i]) + S[i]² + setup.
func batchCost(_ pages: [Int], setup: Int) -> Int {
    let n = pages.count
    var prefix = [0]
    for p in pages { prefix.append(prefix.last! + p) }
    var best = [Int](repeating: 0, count: n + 1)
    var slopes: [Int] = [], intercepts: [Int] = []    // the hull: slopes decreasing
    var head = 0                                      // the line that answered the last query

    func value(_ line: Int, _ x: Int) -> Int { slopes[line] * x + intercepts[line] }
    // Is the middle line b useless once c arrives? True when c overtakes a before b does.
    func useless(_ a: Int, _ b: Int, _ m: Int, _ c: Int) -> Bool {
        (c - intercepts[a]) * (slopes[a] - slopes[b]) <= (intercepts[b] - intercepts[a]) * (slopes[a] - m)
    }
    func add(_ m: Int, _ c: Int) {
        while slopes.count - head >= 2 && useless(slopes.count - 2, slopes.count - 1, m, c) {
            slopes.removeLast()
            intercepts.removeLast()
        }
        slopes.append(m)
        intercepts.append(c)
    }

    add(0, 0)                                         // j = 0: slope -2·0, intercept 0 + 0
    for i in 1...n {
        let x = prefix[i]                             // queries only grow, so the best line only moves right
        while head + 1 < slopes.count && value(head + 1, x) <= value(head, x) {
            head += 1
        }
        best[i] = value(head, x) + x * x + setup
        add(-2 * x, best[i] + x * x)
    }
    return best[n]
}

print(batchCostSlow([1, 3, 2, 4, 1], setup: 10), batchCost([1, 3, 2, 4, 1], setup: 10))
let jobs = (0..<2_000).map { ($0 * 37 + 5) % 10 + 1 }
print(batchCostSlow(jobs, setup: 300), batchCost(jobs, setup: 300))
let many = (0..<100_000).map { ($0 * 37 + 5) % 10 + 1 }
print(batchCost(many, setup: 1_000))
