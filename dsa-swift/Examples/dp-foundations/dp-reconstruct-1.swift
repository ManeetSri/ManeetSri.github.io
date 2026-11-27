// Generated from src/dsa/content/lessons/dp-foundations/dp-reconstruct.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The best haul, and which houses to rob to get it
func robPlan(_ houses: [Int]) -> (total: Int, robbed: [Int]) {
    let n = houses.count
    // best[i] = the most from the first i houses
    var best = Array(repeating: 0, count: n + 1)
    for i in stride(from: 1, through: n, by: 1) {
        best[i] = max(best[i - 1], (i >= 2 ? best[i - 2] : 0) + houses[i - 1])
    }
    // Walk back from the answer, asking which option produced each entry
    var robbed: [Int] = []
    var i = n
    while i >= 1 {
        if best[i] == best[i - 1] {
            i -= 1                     // skipping house i - 1 gives the same total: it wasn't robbed
        } else {
            robbed.append(i - 1)       // house i - 1 was robbed, so its neighbour wasn't
            i -= 2
        }
    }
    return (best[n], robbed.reversed())
}

let plan = robPlan([5, 8, 6, 1, 2, 9])
print("take", plan.total, "from houses", plan.robbed)
print(robPlan([5, 1, 1, 5]).robbed, robPlan([7]).robbed, robPlan([]).robbed)
