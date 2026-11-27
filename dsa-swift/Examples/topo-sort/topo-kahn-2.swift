// Generated from src/dsa/content/lessons/topo-sort/topo-kahn.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func kahn(_ vertices: [String], _ edges: [(String, String)]) -> (order: [String], stuck: [String]) {
    var after: [String: [String]] = [:]
    var inDegree: [String: Int] = [:]
    for vertex in vertices {
        after[vertex] = []
        inDegree[vertex] = 0
    }
    for (u, v) in edges {
        after[u]!.append(v)
        inDegree[v]! += 1
    }
    var order = vertices.filter { inDegree[$0] == 0 }   // the order doubles as the queue
    var head = 0
    while head < order.count {
        let vertex = order[head]
        head += 1
        for next in after[vertex]! {
            inDegree[next]! -= 1
            if inDegree[next] == 0 {
                order.append(next)
            }
        }
    }
    return (order, vertices.filter { inDegree[$0]! > 0 })
}

let steps = ["fetch", "resolve", "compile", "link", "test", "deploy"]
let rules = [("fetch", "resolve"), ("resolve", "compile"), ("compile", "link"),
             ("link", "test"), ("test", "compile"), ("test", "deploy")]
let result = kahn(steps, rules)
print("ordered:", result.order)
print("stuck:", result.stuck)
