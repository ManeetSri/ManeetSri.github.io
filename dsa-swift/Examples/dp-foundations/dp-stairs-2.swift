// Generated from src/dsa/content/lessons/dp-foundations/dp-stairs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Ways to climb n stairs, where each move climbs one of the sizes in `steps`
func climbWays(_ n: Int, steps: [Int]) -> Int {
    // 1. State: ways[i] = the number of ways to stand on stair i
    var ways = Array(repeating: 0, count: n + 1)
    // 3. Base case: one way to be on the ground, by not moving
    ways[0] = 1
    // 4. Order: upwards
    for i in stride(from: 1, through: n, by: 1) {
        // 2. Transition: the last move was one of the step sizes
        for step in steps where step <= i {
            ways[i] += ways[i - step]
        }
    }
    // 5. Answer
    return ways[n]
}

print(climbWays(10, steps: [1, 2]))
print(climbWays(10, steps: [1, 2, 3]))
print(climbWays(10, steps: [2, 5]))
print(climbWays(7, steps: [2, 4]))
