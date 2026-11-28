// Generated from src/dsa/content/lessons/dp-states/dpsm-stocks-1-2.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bestSingleTrade(_ prices: [Int]) -> Int {
    var cheapest = Int.max      // the lowest price seen so far: the best day to have bought
    var best = 0                // no trade at all is allowed, so profit never goes below 0
    for (day, price) in prices.enumerated() {
        cheapest = min(cheapest, price)
        best = max(best, price - cheapest)          // sell today, having bought at the cheapest
        print("day \(day): price \(price), cheapest \(cheapest), best \(best)")
    }
    return best
}

print(bestSingleTrade([9, 4, 7, 2, 8, 5]))
