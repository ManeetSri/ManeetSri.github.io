// Generated from src/dsa/content/lessons/complexity/bigo-analysing-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func loopOfHalvings(_ n: Int) -> Int {
    var steps = 0
    for _ in 0..<n {
        var size = n
        while size > 1 {
            size /= 2
            steps += 1
        }
    }
    return steps
}

func shrinkingPasses(_ n: Int) -> Int {
    var steps = 0
    var size = n
    while size > 0 {
        for _ in 0..<size {
            steps += 1
        }
        size /= 2
    }
    return steps
}

for n in [1_000, 2_000, 4_000] {
    print("n = \(n): n passes of halving \(loopOfHalvings(n)), halving passes of n \(shrinkingPasses(n))")
}
