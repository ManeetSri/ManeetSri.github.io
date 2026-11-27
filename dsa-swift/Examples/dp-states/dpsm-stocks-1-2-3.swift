// Generated from src/dsa/content/lessons/dp-states/dpsm-stocks-1-2.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Two states at the end of each day: holding a share, or free (holding nothing)
func trades(_ prices: [Int], unlimited: Bool) -> Int {
    var hold = Int.min / 2     // best profit while holding: impossible before day 0
    var free = 0               // best profit while holding nothing
    for price in prices {
        let freeYesterday = free
        free = max(free, hold + price)                                // rest, or sell
        hold = max(hold, (unlimited ? freeYesterday : 0) - price)     // keep, or buy
    }
    return free
}

for prices in [[9, 4, 7, 2, 8, 5], [1, 2, 3, 4, 5], [6, 5, 4]] {
    print(prices, "once:", trades(prices, unlimited: false), "many:", trades(prices, unlimited: true))
}
