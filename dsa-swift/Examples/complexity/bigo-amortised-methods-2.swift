// Generated from src/dsa/content/lessons/complexity/bigo-amortised-methods.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Potential: Φ = 2 × count − capacity
var capacity = 0
var count = 0
func potential() -> Int {
    2 * count - capacity
}

for _ in 1...9 {
    let before = potential()
    var actual = 1
    if count == capacity {
        actual += count
        capacity = max(1, 2 * capacity)
    }
    count += 1
    let after = potential()
    print("append \(count): actual \(actual), Φ \(before) → \(after), amortised \(actual + after - before)")
}
