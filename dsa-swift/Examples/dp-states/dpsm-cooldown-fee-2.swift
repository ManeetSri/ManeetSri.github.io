// Generated from src/dsa/content/lessons/dp-states/dpsm-cooldown-fee.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let prices = [4, 6, 5, 11, 7, 12]
let fee = 2

// Tempting but wrong: bank every rise, paying the fee each time it's worth it
var greedy = 0
for day in 1..<prices.count {
    greedy += max(0, prices[day] - prices[day - 1] - fee)
}

// Two states, with the fee paid when a trade closes
var hold = Int.min / 2
var free = 0
for price in prices {
    let freeYesterday = free
    free = max(free, hold + price - fee)       // rest, or sell and pay the fee
    hold = max(hold, freeYesterday - price)    // keep, or buy
}
print("every rise:", greedy)
print("state machine:", free)
