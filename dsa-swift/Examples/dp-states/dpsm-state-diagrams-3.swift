// Generated from src/dsa/content/lessons/dp-states/dpsm-state-diagrams.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// House robber as a state machine: did we rob the house we're standing at?
func robHouses(_ money: [Int]) -> Int {
    var robbed = 0        // best total if we robbed this house
    var skipped = 0       // best total if we didn't
    for amount in money {
        let (oldRobbed, oldSkipped) = (robbed, skipped)
        robbed = oldSkipped + amount            // only from skipped: never two neighbours
        skipped = max(oldRobbed, oldSkipped)    // from either
    }
    return max(robbed, skipped)
}

print(robHouses([2, 7, 9, 3, 1]))
print(robHouses([5, 1, 1, 5]))
