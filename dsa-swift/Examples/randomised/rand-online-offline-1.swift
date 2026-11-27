// Generated from src/dsa/content/lessons/randomised/rand-online-offline.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// Ski rental: renting costs 1 a day, buying costs 10. Three online strategies against hindsight.
let buyPrice = 10

/// What a strategy pays if the season lasts `days` days and it buys at the start of day `buyDay`
func cost(days: Int, buyDay: Int?) -> Int {
    guard let buyDay, buyDay <= days else { return days }    // never bought: rented every day
    return (buyDay - 1) + buyPrice                           // rented until then, then bought
}

func optimal(days: Int) -> Int { min(days, buyPrice) }      // with hindsight: the cheaper of the two

let strategies: [(name: String, buyDay: Int?)] = [("always rent", nil), ("buy at once", 1), ("break-even", buyPrice)]
func padded(_ text: String) -> String { String(repeating: " ", count: 13 - text.count) + text }
print("days  best" + strategies.map { padded($0.name) }.joined())
for days in [1, 5, 9, 10, 11, 30] {
    let costs = strategies.map { padded(String(cost(days: days, buyDay: $0.buyDay))) }
    print(String(format: "%4d  %4d", days, optimal(days: days)) + costs.joined())
}
for strategy in strategies {
    let worst = (1...1_000).map { Double(cost(days: $0, buyDay: strategy.buyDay)) / Double(optimal(days: $0)) }.max()!
    print(strategy.name + String(format: ": worst ratio over 1...1000 days = %.2f", worst))
}
