// Generated from src/dsa/content/lessons/dp-knapsack/dpk-bounded.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// 0/1 knapsack over a list of (weight, value) items, returning the answer and the cells it updated
func zeroOne(_ items: [(weight: Int, value: Int)], _ capacity: Int) -> (best: Int, cells: Int) {
    var best = Array(repeating: 0, count: capacity + 1)
    var cells = 0
    for item in items {
        for w in stride(from: capacity, through: item.weight, by: -1) {
            best[w] = max(best[w], best[w - item.weight] + item.value)
            cells += 1
        }
    }
    return (best[capacity], cells)
}

func pieces(_ k: Int) -> [Int] {
    var result: [Int] = []
    var left = k
    var size = 1
    while size <= left {
        result.append(size)
        left -= size
        size *= 2
    }
    if left > 0 { result.append(left) }
    return result
}

let weights = [3, 4, 5]
let values = [4, 6, 7]
let stock = [40, 5, 100]
let capacity = 200

// One 0/1 item per copy
var copies: [(weight: Int, value: Int)] = []
for i in weights.indices {
    for _ in 0..<min(stock[i], capacity / weights[i]) {   // copies beyond capacity / weight can never fit
        copies.append((weights[i], values[i]))
    }
}

// One 0/1 item per piece: a piece of size p is p copies glued together
var bundles: [(weight: Int, value: Int)] = []
for i in weights.indices {
    for p in pieces(min(stock[i], capacity / weights[i])) {
        bundles.append((p * weights[i], p * values[i]))
    }
}

let slow = zeroOne(copies, capacity)
let fast = zeroOne(bundles, capacity)
print("one item per copy:  \(copies.count) items, best \(slow.best), \(slow.cells) cells updated")
print("binary pieces:      \(bundles.count) items, best \(fast.best), \(fast.cells) cells updated")
