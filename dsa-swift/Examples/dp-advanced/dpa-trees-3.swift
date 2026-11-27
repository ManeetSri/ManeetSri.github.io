// Generated from src/dsa/content/lessons/dp-advanced/dpa-trees.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A general tree as an adjacency list: roads [a, b, length] between n towns
let n = 8
let roads = [[0, 1, 4], [0, 2, 1], [1, 3, 2], [1, 4, 7], [2, 5, 3], [5, 6, 6], [5, 7, 2]]
var neighbours = [[(to: Int, length: Int)]](repeating: [], count: n)
for road in roads {
    neighbours[road[0]].append((road[1], road[2]))
    neighbours[road[1]].append((road[0], road[2]))      // undirected: store both directions
}

// Largest set of towns with no two joined by a road: (best with v in, best with v out)
func independent(_ v: Int, _ parent: Int) -> (with: Int, without: Int) {
    var with = 1
    var without = 0
    for (child, _) in neighbours[v] where child != parent {   // never walk back up
        let sub = independent(child, v)
        with += sub.without
        without += max(sub.with, sub.without)
    }
    return (with, without)
}
let set = independent(0, -1)
print("largest independent set:", max(set.with, set.without))

// Diameter: return the longest path going down from v, record the best path bending at v
var diameter = 0
func longestDown(_ v: Int, _ parent: Int) -> Int {
    var first = 0, second = 0                  // the two longest downward paths through different children
    for (child, length) in neighbours[v] where child != parent {
        let path = longestDown(child, v) + length
        if path > first {
            second = first
            first = path
        } else if path > second {
            second = path
        }
    }
    diameter = max(diameter, first + second)
    return first
}
_ = longestDown(0, -1)
print("diameter:", diameter)
