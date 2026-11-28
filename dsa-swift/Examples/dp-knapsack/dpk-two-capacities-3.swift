// Generated from src/dsa/content/lessons/dp-knapsack/dpk-two-capacities.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Projects: each needs some volunteers and raises some money. With at most 4 volunteers in total,
// how many sets of projects raise at least 5?
let needs = [2, 3, 1]
let raises = [4, 5, 1]
let volunteers = 4
let goal = 5

// ways[v][f]: sets using at most v volunteers whose money, capped at the goal, is exactly f
var ways = Array(repeating: Array(repeating: 0, count: goal + 1), count: volunteers + 1)
for v in 0...volunteers {
    ways[v][0] = 1                                       // the empty set fits any budget and raises 0
}
for (need, raise) in zip(needs, raises) {
    for v in stride(from: volunteers, through: need, by: -1) {
        for f in stride(from: goal, through: 0, by: -1) {
            let capped = min(goal, f + raise)            // "at least the goal" all lands in one column
            ways[v][capped] += ways[v - need][f]
        }
    }
}
print("plans that reach the goal:", ways[volunteers][goal])

// Brute force over every set of projects
var count = 0
for mask in 0..<(1 << needs.count) {
    let chosen = needs.indices.filter { mask & (1 << $0) != 0 }
    let people = chosen.map { needs[$0] }.reduce(0, +)
    let money = chosen.map { raises[$0] }.reduce(0, +)
    if people <= volunteers && money >= goal { count += 1 }
}
print("brute force:", count)
