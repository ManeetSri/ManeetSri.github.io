// Generated from src/dsa/content/lessons/dp-states/dpsm-state-diagrams.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func cooldownCorrect(_ prices: [Int]) -> Int {
    var hold = Int.min / 2, sold = 0, rest = 0
    for price in prices {
        let (oldHold, oldSold, oldRest) = (hold, sold, rest)
        hold = max(oldHold, oldRest - price)
        sold = oldHold + price
        rest = max(oldRest, oldSold)
    }
    return max(sold, rest)
}

func cooldownInPlace(_ prices: [Int]) -> Int {
    var hold = Int.min / 2, sold = 0, rest = 0
    for price in prices {
        sold = hold + price
        hold = max(hold, rest - price)
        rest = max(rest, sold)        // Bug: today's sold, so tomorrow's buy skips the cooldown
    }
    return max(sold, rest)
}

print(cooldownCorrect([1, 3, 1, 3]), cooldownInPlace([1, 3, 1, 3]))
