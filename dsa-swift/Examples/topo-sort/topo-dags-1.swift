// Generated from src/dsa/content/lessons/topo-sort/topo-dags.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Each target and the targets it needs, as in a Package.swift
let needs: [(target: String, needs: [String])] = [
    ("Models", []),
    ("DesignSystem", []),
    ("Networking", ["Models"]),
    ("Widgets", ["Models", "DesignSystem"]),
    ("App", ["Networking", "Models", "DesignSystem"]),
    ("AppTests", ["App"]),
]

// Edges point from what must come first to what needs it
var edges: [(before: String, after: String)] = []
for (target, requirements) in needs {
    for requirement in requirements {
        edges.append((before: requirement, after: target))
    }
}
print(edges.count, "edges")

func isTopologicalOrder(_ order: [String]) -> Bool {
    let targets = needs.map(\.target)
    guard order.count == targets.count, Set(order) == Set(targets) else { return false }  // each once
    var position: [String: Int] = [:]
    for (index, target) in order.enumerated() {
        position[target] = index
    }
    return edges.allSatisfy { position[$0.before]! < position[$0.after]! }
}

print(isTopologicalOrder(["Models", "DesignSystem", "Networking", "Widgets", "App", "AppTests"]))
print(isTopologicalOrder(["DesignSystem", "Models", "Widgets", "Networking", "App", "AppTests"]))
print(isTopologicalOrder(["Models", "Networking", "App", "DesignSystem", "Widgets", "AppTests"]))

// In-degree: how many targets each one waits for
var inDegree: [String: Int] = [:]
for (target, _) in needs {
    inDegree[target] = 0
}
for edge in edges {
    inDegree[edge.after]! += 1
}
print(needs.map { "\($0.target) \(inDegree[$0.target]!)" })
print("can start straight away:", needs.map(\.target).filter { inDegree[$0] == 0 })
