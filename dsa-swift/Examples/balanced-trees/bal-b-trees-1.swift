// Generated from src/dsa/content/lessons/balanced-trees/bal-b-trees.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// How many levels does a tree need to hold n keys, if each node has `fanOut` children?
func levelsNeeded(_ n: Int, fanOut: Int) -> Int {
    var levels = 0
    var reach = 1                       // how many keys' worth of leaves `levels` levels can address
    while reach < n {
        reach *= fanOut
        levels += 1
    }
    return levels
}

for n in [1_000_000, 1_000_000_000] {
    let row = [2, 16, 128, 512].map { "fan-out \($0): \(levelsNeeded(n, fanOut: $0))" }
    print("\(n) keys →", row.joined(separator: ", "))
}
