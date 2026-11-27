// Generated from src/dsa/content/lessons/dp-foundations/dp-space.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Ways to climb n stairs taking 1, 2 or 3 at a time, keeping only four answers
func climbWays(_ n: Int) -> Int {
    var recent = [1, 0, 0, 0]                  // recent[i % 4] holds ways(i); ways(0) = 1
    for i in stride(from: 1, through: n, by: 1) {
        var total = 0
        for step in 1...3 where step <= i {
            total += recent[(i - step) % 4]
        }
        recent[i % 4] = total
    }
    return recent[n % 4]
}

print((0...10).map(climbWays))
