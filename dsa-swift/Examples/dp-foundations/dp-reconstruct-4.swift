// Generated from src/dsa/content/lessons/dp-foundations/dp-reconstruct.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Backwards: fill "the first i houses", then walk back from the end, skipping on ties
func walkBackPlan(_ houses: [Int]) -> [Int] {
    let n = houses.count
    var best = Array(repeating: 0, count: n + 1)
    for i in stride(from: 1, through: n, by: 1) {
        best[i] = max(best[i - 1], (i >= 2 ? best[i - 2] : 0) + houses[i - 1])
    }
    var robbed: [Int] = []
    var i = n
    while i >= 1 {
        if best[i] == best[i - 1] {
            i -= 1
        } else {
            robbed.append(i - 1)
            i -= 2
        }
    }
    return robbed.reversed()
}

/// Forwards: fill "houses i to the end", then walk forwards from house 0, robbing whenever that still
/// reaches the best total. This gives the best plan whose list of houses comes first in dictionary order.
func earliestPlan(_ houses: [Int]) -> [Int] {
    let n = houses.count
    var fromHere = Array(repeating: 0, count: n + 2)   // fromHere[i]: the most from houses i...n - 1
    for i in stride(from: n - 1, through: 0, by: -1) {
        fromHere[i] = max(fromHere[i + 1], houses[i] + fromHere[i + 2])
    }
    var robbed: [Int] = []
    var i = 0
    while i < n {
        if houses[i] + fromHere[i + 2] == fromHere[i] {
            robbed.append(i)
            i += 2
        } else {
            i += 1
        }
    }
    return robbed
}

for street in [[2, 3, 1], [1, 1, 1, 2, 1], [5, 8, 6, 1, 2, 9]] {
    print(street, "walk back:", walkBackPlan(street), "earliest:", earliestPlan(street))
}
