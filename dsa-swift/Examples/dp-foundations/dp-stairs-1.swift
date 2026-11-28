// Generated from src/dsa/content/lessons/dp-foundations/dp-stairs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Ways to climb n stairs taking 1 or 2 at a time
func climbWays(_ n: Int) -> Int {
    var (twoBelow, oneBelow) = (0, 1)        // ways(i - 2) and ways(i - 1), starting at i = 1: ways(-1) = 0, ways(0) = 1
    for _ in stride(from: 1, through: n, by: 1) {
        (twoBelow, oneBelow) = (oneBelow, oneBelow + twoBelow)
    }
    return oneBelow
}

print((0...10).map(climbWays))
