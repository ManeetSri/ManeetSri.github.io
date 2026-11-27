// Generated from src/dsa/content/lessons/complexity/bigo-analysing-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func harmonicSteps(_ n: Int) -> Int {
    var steps = 0
    for gap in 1...n {
        for _ in stride(from: 0, to: n, by: gap) {
            steps += 1
        }
    }
    return steps
}

for n in [1_000, 10_000] {
    print("n = \(n): \(harmonicSteps(n)) steps")
}
