// Generated from src/dsa/content/lessons/greedy/greedy-counterexamples.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let items = [(name: "lamp", weight: 6, value: 30), (name: "rug", weight: 5, value: 20), (name: "vase", weight: 5, value: 20)]
let capacity = 10

// Greedy by value per kg, taking each item that still fits
var room = capacity
var greedyValue = 0
for item in items.sorted(by: { $0.value * $1.weight > $1.value * $0.weight }) where item.weight <= room {
    print("greedy takes the \(item.name)")
    room -= item.weight
    greedyValue += item.value
}

// Try every subset
var best = 0
for mask in 0..<(1 << items.count) {
    let chosen = items.indices.filter { mask & (1 << $0) != 0 }
    let weight = chosen.reduce(0) { $0 + items[$1].weight }
    if weight <= capacity { best = max(best, chosen.reduce(0) { $0 + items[$1].value }) }
}
print("greedy \(greedyValue), best \(best)")
