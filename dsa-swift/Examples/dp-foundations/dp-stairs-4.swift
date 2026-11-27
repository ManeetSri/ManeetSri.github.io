// Generated from src/dsa/content/lessons/dp-foundations/dp-stairs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Each stair has a toll, paid whenever you stand on it. Start on stair 0 or stair 1, climb 1 or 2
/// stairs at a time, and finish on the landing just above the last stair, which is free.
func cheapestClimb(_ tolls: [Int]) -> Int {
    let n = tolls.count
    // 1. State: reach[i] = the cheapest total paid to arrive at position i (not counting i's own toll)
    var reach = Array(repeating: 0, count: n + 1)
    // 3. Base case: reach[0] = reach[1] = 0, because you may start on either for free
    // 4. Order: upwards
    for i in stride(from: 2, through: n, by: 1) {
        // 2. Transition: arrive from one stair below or two, paying the toll of the stair you left
        reach[i] = min(reach[i - 1] + tolls[i - 1], reach[i - 2] + tolls[i - 2])
    }
    print("reach:", reach)
    // 5. Answer: position n is the landing
    return reach[n]
}

print(cheapestClimb([3, 8, 2, 9, 4, 1, 7]))
print(cheapestClimb([5, 1, 5, 1, 5]))
