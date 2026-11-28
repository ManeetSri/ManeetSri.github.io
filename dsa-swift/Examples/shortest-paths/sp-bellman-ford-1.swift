// Generated from src/dsa/content/lessons/shortest-paths/sp-bellman-ford.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = ["S", "A", "B", "C", "D"]
// Directed edges as (from, to, weight), listed in an unhelpful order: A→C, C→D, S→A, S→B, B→A
let edges = [(1, 3, 3), (3, 4, 1), (0, 1, 2), (0, 2, 5), (2, 1, -4)]
let infinity = Int.max / 2

func show(_ distance: [Int]) -> String {
    zip(names, distance).map { "\($0) \($1 == infinity ? "∞" : String($1))" }.joined(separator: ", ")
}

var distance = Array(repeating: infinity, count: names.count)
distance[0] = 0
for round in 1..<names.count {                 // V − 1 rounds
    var changed = false
    for (from, to, weight) in edges {
        guard distance[from] != infinity else { continue }   // can't extend a path that doesn't exist
        if distance[from] + weight < distance[to] {
            distance[to] = distance[from] + weight
            changed = true
        }
    }
    print("after round \(round): \(show(distance))")
    if !changed { break }                      // a quiet round means every distance is final
}
