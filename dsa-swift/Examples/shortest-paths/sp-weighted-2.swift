// Generated from src/dsa/content/lessons/shortest-paths/sp-weighted.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = ["home", "park", "shop", "school"]
// Each road once per direction, as (from, to, minutes)
let roads = [(0, 3, 10), (3, 0, 10), (0, 1, 2), (1, 0, 2), (1, 2, 3), (2, 1, 3), (2, 3, 2), (3, 2, 2)]

let infinity = Int.max / 2                    // "not reached yet", with room to add to it
var distance = Array(repeating: infinity, count: names.count)
distance[0] = 0

/// Relaxation: does going through `from` give `to` a shorter path?
func relax(_ from: Int, _ to: Int, _ weight: Int) -> Bool {
    if distance[from] + weight < distance[to] {
        distance[to] = distance[from] + weight
        return true
    }
    return false
}

var pass = 0
var changed = true
while changed {
    changed = false
    pass += 1
    for (from, to, weight) in roads {
        if relax(from, to, weight) {
            print("pass \(pass): \(names[to]) improves to \(distance[to]) via \(names[from])")
            changed = true
        }
    }
}
print("passes:", pass, "distances:", distance)
