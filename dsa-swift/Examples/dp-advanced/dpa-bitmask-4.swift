// Generated from src/dsa/content/lessons/dp-advanced/dpa-bitmask.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Each volunteer needs one time slot from their own list, and a slot fits one volunteer at most.
// Count the ways to place everyone. Few volunteers, many slots: the mask is over the volunteers.
func placements(volunteers: [[Int]], slots: Int) -> Int {
    let n = volunteers.count
    var wants = [[Int]](repeating: [], count: slots)     // wants[slot]: the volunteers who can take it
    for (person, list) in volunteers.enumerated() {
        for slot in list { wants[slot].append(person) }
    }
    // ways[mask]: ways to place exactly the volunteers in mask using the slots handled so far
    var ways = [Int](repeating: 0, count: 1 << n)
    ways[0] = 1
    for slot in 0..<slots {
        var next = ways                                   // the slot stays empty
        for mask in 0..<(1 << n) where ways[mask] > 0 {
            for person in wants[slot] where mask & (1 << person) == 0 {
                next[mask | (1 << person)] += ways[mask]  // or it goes to someone still waiting
            }
        }
        ways = next
    }
    return ways[(1 << n) - 1]
}

print(placements(volunteers: [[0, 1], [1, 2], [0, 2, 3]], slots: 4))
let many = (0..<10).map { person in (0..<40).filter { ($0 * 7 + person * 3) % 5 < 2 } }
print(placements(volunteers: many, slots: 40))
