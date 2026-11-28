// Generated from src/dsa/content/lessons/complexity/bigo-amortised.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Elements copied over n appends, for two ways of growing a full array
func copies(appends n: Int, grow: (Int) -> Int) -> Int {
    var capacity = 1
    var copied = 0
    for count in 0..<n where count == capacity {
        copied += count
        capacity = grow(capacity)
    }
    return copied
}

for n in [1_000, 10_000, 100_000] {
    let doubling = copies(appends: n) { $0 * 2 }
    let plusTen = copies(appends: n) { $0 + 10 }
    print("n = \(n): doubling copies \(doubling), adding 10 copies \(plusTen)")
}
