// Generated from src/dsa/content/lessons/range-queries/rq-offline.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// For each budget, how many prices are within it? Offline: sort both, sweep once, answer in input order
func affordableCounts(prices: [Int], budgets: [Int]) -> [Int] {
    let sortedPrices = prices.sorted()
    let order = budgets.indices.sorted { budgets[$0] < budgets[$1] }    // query numbers, smallest budget first
    var answers = [Int](repeating: 0, count: budgets.count)
    var affordable = 0                                                  // prices ≤ the current budget
    for q in order {
        while affordable < sortedPrices.count && sortedPrices[affordable] <= budgets[q] {
            affordable += 1
        }
        answers[q] = affordable
    }
    return answers
}

print(affordableCounts(prices: [5, 2, 8, 6, 3, 9, 1, 7], budgets: [5, 0, 10, 6, 1]))
