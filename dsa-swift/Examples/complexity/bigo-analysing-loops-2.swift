// Generated from src/dsa/content/lessons/complexity/bigo-analysing-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func halvings(_ n: Int) -> Int {
    var steps = 0
    var size = n
    while size > 1 {
        size /= 2
        steps += 1
    }
    return steps
}

func doublings(_ n: Int) -> Int {
    var steps = 0
    var width = 1
    while width < n {
        width *= 2
        steps += 1
    }
    return steps
}

for n in [1, 2, 3, 4, 5, 1_000, 1_000_000, 1_000_000_000] {
    print("n = \(n): halvings \(halvings(n)), doublings \(doublings(n))")
}
