// Generated from src/dsa/content/lessons/dp-knapsack/dpk-unbounded.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The same items, packed two ways. Weights 3 and 4 with values 5 and 7, capacity 10.
let weights = [3, 4]
let values = [5, 7]
let capacity = 10

func pack(copiesAllowed: Bool) -> [Int] {
    var best = Array(repeating: 0, count: capacity + 1)
    for (weight, value) in zip(weights, values) {
        let rooms = copiesAllowed ? Array(stride(from: weight, through: capacity, by: 1))   // left to right
                                  : Array(stride(from: capacity, through: weight, by: -1))  // right to left
        for w in rooms {
            best[w] = max(best[w], best[w - weight] + value)
        }
    }
    return best
}

print("0/1:      ", pack(copiesAllowed: false))
print("unbounded:", pack(copiesAllowed: true))
