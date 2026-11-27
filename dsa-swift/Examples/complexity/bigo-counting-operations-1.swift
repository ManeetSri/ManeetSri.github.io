// Generated from src/dsa/content/lessons/complexity/bigo-counting-operations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func singleLoopSteps(_ n: Int) -> Int {
    var steps = 0
    for _ in 0..<n {
        steps += 1
    }
    return steps
}

func nestedLoopSteps(_ n: Int) -> Int {
    var steps = 0
    for _ in 0..<n {
        for _ in 0..<n {
            steps += 1
        }
    }
    return steps
}

for n in [10, 100, 1_000] {
    print("n = \(n): single \(singleLoopSteps(n)), nested \(nestedLoopSteps(n))")
}
