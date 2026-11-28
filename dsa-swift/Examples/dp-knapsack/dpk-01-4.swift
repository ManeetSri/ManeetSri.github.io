// Generated from src/dsa/content/lessons/dp-knapsack/dpk-01.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// One item: weight 2, value 3. Capacity 6. It may be packed at most once.
let weight = 2
let value = 3
let capacity = 6

func pass(rightToLeft: Bool) {
    var best = Array(repeating: 0, count: capacity + 1)
    let rooms = rightToLeft ? Array(stride(from: capacity, through: weight, by: -1)) : Array(weight...capacity)
    for w in rooms {
        let candidate = best[w - weight] + value
        print("  best[\(w)] = max(\(best[w]), best[\(w - weight)] + \(value)) = \(max(best[w], candidate))")
        best[w] = max(best[w], candidate)
    }
    print("  row:", best)
}

print("left to right:")
pass(rightToLeft: false)
print("right to left:")
pass(rightToLeft: true)
