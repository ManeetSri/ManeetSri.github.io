// Generated from src/dsa/content/lessons/topo-sort/topo-dfs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let clothes = ["shirt", "tie", "jacket", "trousers", "belt", "shoes", "socks"]
let after: [String: [String]] = [
    "shirt": ["belt", "tie"], "tie": ["jacket"], "trousers": ["belt", "shoes"],
    "belt": ["jacket"], "socks": ["shoes"],
]

var visited: Set<String> = []
var finished: [String] = []

func visit(_ vertex: String) {
    visited.insert(vertex)
    for next in after[vertex, default: []] where !visited.contains(next) {
        visit(next)
    }
    finished.append(vertex)                     // everything it leads to has finished
}

for vertex in clothes where !visited.contains(vertex) {
    visit(vertex)                               // restart from every vertex not yet reached
}
print("finishing order:", finished)
print("topological order:", finished.reversed().joined(separator: " → "))
