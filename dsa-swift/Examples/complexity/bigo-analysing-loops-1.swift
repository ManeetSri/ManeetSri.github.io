// Generated from src/dsa/content/lessons/complexity/bigo-analysing-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func triangleSteps(_ n: Int) -> Int {
    var steps = 0
    for i in 0..<n {
        for _ in 0..<i {
            steps += 1
        }
    }
    return steps
}

for n in [5, 10, 100, 1_000] {
    print("n = \(n): counted \(triangleSteps(n)), formula \(n * (n - 1) / 2), n² = \(n * n)")
}
