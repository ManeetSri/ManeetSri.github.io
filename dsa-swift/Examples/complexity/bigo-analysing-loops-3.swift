// Generated from src/dsa/content/lessons/complexity/bigo-analysing-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func divisions(of n: Int, by divisor: Int) -> Int {
    var steps = 0
    var size = n
    while size > 1 {
        size /= divisor
        steps += 1
    }
    return steps
}

for n in [1_000, 1_000_000, 1_000_000_000, 1_000_000_000_000_000_000] {
    print("n = \(n): by 2 takes \(divisions(of: n, by: 2)), by 10 takes \(divisions(of: n, by: 10))")
}
