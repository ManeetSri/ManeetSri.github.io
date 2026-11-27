// Generated from src/dsa/content/lessons/dp-foundations/dp-stairs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let modulus = 1_000_000_007

/// Ways to climb n stairs taking 1 or 2 at a time, modulo 1,000,000,007
func climbWaysMod(_ n: Int) -> Int {
    var (twoBelow, oneBelow) = (0, 1)
    for _ in stride(from: 1, through: n, by: 1) {
        (twoBelow, oneBelow) = (oneBelow, (oneBelow + twoBelow) % modulus)
    }
    return oneBelow
}

print(climbWaysMod(10))
print(climbWaysMod(100))
print(climbWaysMod(100_000))
