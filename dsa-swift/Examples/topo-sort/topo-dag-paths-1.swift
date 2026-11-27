// Generated from src/dsa/content/lessons/topo-sort/topo-dag-paths.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = ["depot", "A", "B", "C", "D", "port"]
let edges = [[0, 1, 4], [0, 2, 1], [2, 1, 2], [1, 3, 3], [2, 3, 6], [1, 4, 7], [3, 4, -2], [3, 5, 5], [4, 5, 2]]
let n = names.count
var out = Array(repeating: [(to: Int, weight: Int)](), count: n)
var waitingOn = Array(repeating: 0, count: n)
for edge in edges {
    out[edge[0]].append((to: edge[1], weight: edge[2]))
    waitingOn[edge[1]] += 1
}

// A topological order, from Kahn's algorithm
var order = (0..<n).filter { waitingOn[$0] == 0 }
var head = 0
while head < order.count {
    let u = order[head]
    head += 1
    for (v, _) in out[u] {
        waitingOn[v] -= 1
        if waitingOn[v] == 0 { order.append(v) }
    }
}

func bestPaths(from source: Int, longest: Bool) -> (distance: [Int?], previous: [Int?]) {
    var distance = [Int?](repeating: nil, count: n)     // nil: not reached yet
    var previous = [Int?](repeating: nil, count: n)
    distance[source] = 0
    for u in order {
        guard let du = distance[u] else { continue }    // unreachable from the source
        for (v, weight) in out[u] {
            let candidate = du + weight
            let better = distance[v].map { longest ? candidate > $0 : candidate < $0 } ?? true
            if better {
                distance[v] = candidate                 // relax the edge u → v
                previous[v] = u
            }
        }
    }
    return (distance, previous)
}

func route(to target: Int, _ previous: [Int?]) -> String {
    var stops: [String] = []
    var current: Int? = target
    while let vertex = current {
        stops.append(names[vertex])
        current = previous[vertex]
    }
    return stops.reversed().joined(separator: " → ")
}

print("order:", order.map { names[$0] })
let cheapest = bestPaths(from: 0, longest: false)
print("cheapest:", names.indices.map { "\(names[$0]) \(cheapest.distance[$0]!)" })
print("cheapest to port:", route(to: 5, cheapest.previous))
let dearest = bestPaths(from: 0, longest: true)
print("longest to port:", dearest.distance[5]!, "via", route(to: 5, dearest.previous))
