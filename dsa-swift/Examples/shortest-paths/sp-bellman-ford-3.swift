// Generated from src/dsa/content/lessons/shortest-paths/sp-bellman-ford.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let infinity = Int.max / 2
// S=0, A=1, B=2, T=3: a cheap three-edge route S→A→B→T and an expensive direct S→T
let edges = [(0, 1, 1), (1, 2, 1), (2, 3, 1), (0, 3, 10)]

/// Cheapest cost from 0 to 3 using at most `maxEdges` edges
func cheapest(maxEdges: Int, copying: Bool) -> Int {
    var distance = Array(repeating: infinity, count: 4)
    distance[0] = 0
    for _ in 0..<maxEdges {
        let before = copying ? distance : []   // the snapshot from the start of this round
        for (from, to, weight) in edges {
            let start = copying ? before[from] : distance[from]
            if start != infinity && start + weight < distance[to] {
                distance[to] = start + weight
            }
        }
    }
    return distance[3]
}

for k in 1...3 {
    print("at most \(k) edge(s): copying \(cheapest(maxEdges: k, copying: true)), in place \(cheapest(maxEdges: k, copying: false))")
}
