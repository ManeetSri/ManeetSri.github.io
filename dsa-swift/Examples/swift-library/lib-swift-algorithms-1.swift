// Generated from src/dsa/content/lessons/swift-library/lib-swift-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A stand-in for swift-algorithms' combinations(ofCount:), in the same order
func combinations<T>(of items: [T], count: Int) -> [[T]] {
    var result: [[T]] = []
    var chosen: [T] = []
    func choose(from start: Int) {
        if chosen.count == count {
            result.append(chosen)
            return
        }
        guard start < items.count else { return }
        for index in start..<items.count {
            chosen.append(items[index])
            choose(from: index + 1)
            chosen.removeLast()
        }
    }
    choose(from: 0)
    return result
}

let toppings = ["ham", "olive", "pepper", "onion"]
for pair in combinations(of: toppings, count: 2) {
    print(pair)
}
print(combinations(of: toppings, count: 3).count)
print(combinations(of: toppings, count: 5).count)
print(combinations(of: [3, 1, 2], count: 2))
