// Generated from src/dsa/content/lessons/complexity/bigo-little-o.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// floor(log₂ n), by counting halvings
func log2Floor(_ n: Int) -> Int {
    var steps = 0
    var size = n
    while size > 1 {
        size /= 2
        steps += 1
    }
    return steps
}

func ratio(_ top: Int, _ bottom: Int) -> Double {
    (Double(top) / Double(bottom) * 10_000).rounded() / 10_000
}

for n in [10, 100, 1_000, 10_000] {
    print("n = \(n): (3n + 2)/n = \(ratio(3 * n + 2, n)), log n / n = \(ratio(log2Floor(n), n)), n / n² = \(ratio(n, n * n))")
}
