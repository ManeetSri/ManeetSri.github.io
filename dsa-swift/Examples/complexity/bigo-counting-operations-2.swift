// Generated from src/dsa/content/lessons/complexity/bigo-counting-operations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func halvingSteps(_ n: Int) -> Int {
    var steps = 0
    var size = n
    while size > 1 {
        size /= 2
        steps += 1
    }
    return steps
}

func linearSteps(_ n: Int) -> Int {
    var steps = 0
    for _ in 0..<n {
        steps += 1
    }
    return steps
}

func quadraticSteps(_ n: Int) -> Int {
    var steps = 0
    for _ in 0..<n {
        for _ in 0..<n {
            steps += 1
        }
    }
    return steps
}

for n in [100, 200, 400, 800] {
    print("n = \(n): halving \(halvingSteps(n)), linear \(linearSteps(n)), quadratic \(quadraticSteps(n))")
}
