// Generated from src/dsa/content/lessons/dp-states/dpsm-state-diagrams.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func show(_ value: Int) -> String {
    value < -1_000_000 ? "−∞" : String(value)      // print "impossible" readably
}

func maxProfitWithCooldown(_ prices: [Int]) -> Int {
    var hold = Int.min / 2        // holding a share
    var sold = 0                  // sold today, so tomorrow must be a rest
    var rest = 0                  // holding nothing and free to buy
    print("start: hold \(show(hold)), sold \(sold), rest \(rest)")
    for (day, price) in prices.enumerated() {
        let (oldHold, oldSold, oldRest) = (hold, sold, rest)   // every arrow starts from yesterday
        hold = max(oldHold, oldRest - price)                   // keep, or buy from rest
        sold = oldHold + price                                 // sell: the only arrow into sold
        rest = max(oldRest, oldSold)                           // keep resting, or finish the cooldown
        print("day \(day), price \(price): hold \(show(hold)), sold \(show(sold)), rest \(rest)")
    }
    return max(sold, rest)
}

print("best:", maxProfitWithCooldown([3, 1, 4, 2, 5, 0, 3]))
