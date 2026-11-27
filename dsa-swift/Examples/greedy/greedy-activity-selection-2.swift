// Generated from src/dsa/content/lessons/greedy/greedy-activity-selection.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Item {
    let name: String
    let weight: Int        // kilograms available
    let value: Int         // the value of all of it
}

// Fractional knapsack: densest first, and a fraction of the first item that doesn't fit
func bestLoad(_ items: [Item], capacity: Int) -> Double {
    // Higher value per kg first; a.value / a.weight > b.value / b.weight, without dividing
    let densestFirst = items.sorted { $0.value * $1.weight > $1.value * $0.weight }
    var room = capacity
    var total = 0.0
    for item in densestFirst where room > 0 {
        let take = min(item.weight, room)
        let worth = Double(item.value) * Double(take) / Double(item.weight)
        print("\(take) kg of the \(item.weight) kg of \(item.name): \(worth)")
        total += worth
        room -= take
    }
    return total
}

let stall = [
    Item(name: "tea", weight: 4, value: 20),
    Item(name: "coffee", weight: 6, value: 18),
    Item(name: "cocoa", weight: 5, value: 35),
    Item(name: "sugar", weight: 8, value: 8),
]
print("total", bestLoad(stall, capacity: 10))
