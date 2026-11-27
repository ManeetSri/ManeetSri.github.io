// Generated from src/dsa/content/lessons/dp-foundations/dp-house-robber.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Greedy: keep taking the richest house that doesn't sit next to one already taken
func richestFirst(_ houses: [Int]) -> Int {
    var taken = Array(repeating: false, count: houses.count)
    var total = 0
    for i in houses.indices.sorted(by: { houses[$0] > houses[$1] }) {
        let leftFree = i == 0 || !taken[i - 1]
        let rightFree = i == houses.count - 1 || !taken[i + 1]
        if leftFree && rightFree {
            taken[i] = true
            total += houses[i]
        }
    }
    return total
}

/// Take every other house: the better of the even positions and the odd positions
func everyOther(_ houses: [Int]) -> Int {
    let even = houses.indices.filter { $0 % 2 == 0 }.map { houses[$0] }.reduce(0, +)
    let odd = houses.indices.filter { $0 % 2 == 1 }.map { houses[$0] }.reduce(0, +)
    return max(even, odd)
}

/// Try every plan: rob house i or not, never two neighbours
func bestOfAll(_ houses: [Int], from i: Int = 0) -> Int {
    if i >= houses.count {
        return 0
    }
    return max(bestOfAll(houses, from: i + 1), houses[i] + bestOfAll(houses, from: i + 2))
}

for street in [[3, 4, 3], [5, 1, 1, 5], [5, 8, 6, 1, 2, 9]] {
    print(street, "richest first:", richestFirst(street), "every other:", everyOther(street), "best:", bestOfAll(street))
}
