// Generated from src/dsa/content/lessons/complexity/bigo-rules.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sequentialSteps(_ n: Int, _ m: Int) -> Int {
    var steps = 0
    for _ in 0..<n {
        steps += 1
    }
    for _ in 0..<m {
        steps += 1
    }
    return steps
}

func nestedSteps(_ n: Int, _ m: Int) -> Int {
    var steps = 0
    for _ in 0..<n {
        for _ in 0..<m {
            steps += 1
        }
    }
    return steps
}

for (n, m) in [(10, 1_000), (1_000, 10), (1_000, 1_000)] {
    print("n = \(n), m = \(m): one after the other \(sequentialSteps(n, m)), one inside the other \(nestedSteps(n, m))")
}
