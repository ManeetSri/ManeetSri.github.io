// Generated from src/dsa/content/lessons/topo-sort/topo-kahn.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func topologicalOrder(_ vertices: [String], _ edges: [(String, String)]) -> [String]? {
    var after: [String: [String]] = [:]                 // u → the vertices that wait for u
    var inDegree: [String: Int] = [:]
    for vertex in vertices {
        after[vertex] = []
        inDegree[vertex] = 0
    }
    for (u, v) in edges {
        after[u]!.append(v)
        inDegree[v]! += 1
    }

    var queue = vertices.filter { inDegree[$0] == 0 }   // waiting for nothing
    var head = 0
    var order: [String] = []
    while head < queue.count {
        let vertex = queue[head]
        head += 1
        order.append(vertex)
        for next in after[vertex]! {
            inDegree[next]! -= 1                        // one fewer thing to wait for
            if inDegree[next] == 0 {
                queue.append(next)                      // everything before it is done
            }
        }
    }
    return order.count == vertices.count ? order : nil  // nil: some vertices never became ready
}

let clothes = ["shirt", "tie", "jacket", "trousers", "belt", "shoes", "socks"]
let dressing = [("shirt", "belt"), ("shirt", "tie"), ("tie", "jacket"), ("trousers", "belt"),
                ("trousers", "shoes"), ("belt", "jacket"), ("socks", "shoes")]
print(topologicalOrder(clothes, dressing)!.joined(separator: " → "))
