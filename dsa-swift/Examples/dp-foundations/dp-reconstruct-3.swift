// Generated from src/dsa/content/lessons/dp-foundations/dp-reconstruct.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// House robber with rolling values, but one Bool per house recording the decision
func robPlan(_ houses: [Int]) -> [Int] {
    let n = houses.count
    var took = Array(repeating: false, count: n + 1)   // took[i]: did the best for the first i houses rob house i - 1?
    var (twoBack, oneBack) = (0, 0)
    for i in stride(from: 1, through: n, by: 1) {
        let take = twoBack + houses[i - 1]
        took[i] = take > oneBack
        (twoBack, oneBack) = (oneBack, max(oneBack, take))
    }
    var robbed: [Int] = []
    var i = n
    while i >= 1 {
        if took[i] {
            robbed.append(i - 1)
            i -= 2
        } else {
            i -= 1
        }
    }
    return robbed.reversed()
}

print(robPlan([5, 8, 6, 1, 2, 9]))
