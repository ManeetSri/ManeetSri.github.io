// Generated from src/dsa/content/lessons/dp-states/dpsm-cooldown-fee.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Three states: hold, sold (cooling down), rest
func threeStates(_ prices: [Int]) -> Int {
    var hold = Int.min / 2, sold = 0, rest = 0
    for price in prices {
        let (oldHold, oldSold, oldRest) = (hold, sold, rest)
        hold = max(oldHold, oldRest - price)
        sold = oldHold + price
        rest = max(oldRest, oldSold)
    }
    return max(sold, rest)
}

// Two states: hold and free. A buy must start from "free two days ago".
func twoStates(_ prices: [Int]) -> Int {
    var hold = Int.min / 2
    var free = 0                 // free at the end of yesterday
    var freeTwoDaysAgo = 0       // free at the end of the day before
    for price in prices {
        let freeYesterday = free
        free = max(free, hold + price)              // rest, or sell
        hold = max(hold, freeTwoDaysAgo - price)    // keep, or buy: skipping yesterday is the cooldown
        freeTwoDaysAgo = freeYesterday
    }
    return free
}

for prices in [[3, 1, 4, 2, 5, 0, 3], [1, 3, 1, 3], [2, 9, 1, 8, 3, 7], [5, 4, 3, 2]] {
    print(prices, threeStates(prices), twoStates(prices))
}
