// Generated from src/dsa/content/lessons/topo-sort/topo-dfs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Colour { case white, grey, black }

// A topological order, or the first cycle found
func dfsOrder(_ vertices: [String], _ after: [String: [String]]) -> (order: [String], cycle: [String]) {
    var colour: [String: Colour] = [:]
    for vertex in vertices {
        colour[vertex] = .white
    }
    var path: [String] = []                       // the grey vertices: the current chain of calls
    var finished: [String] = []
    var cycle: [String] = []

    func visit(_ vertex: String) {
        colour[vertex] = .grey
        path.append(vertex)
        for next in after[vertex, default: []] where cycle.isEmpty {
            switch colour[next]! {
            case .white:
                visit(next)
            case .grey:                           // an edge back into the current path
                cycle = Array(path[path.firstIndex(of: next)!...]) + [next]
            case .black:
                break                             // finished earlier: nothing new down there
            }
        }
        path.removeLast()
        colour[vertex] = .black
        finished.append(vertex)
    }

    for vertex in vertices where colour[vertex] == .white && cycle.isEmpty {
        visit(vertex)
    }
    return cycle.isEmpty ? (finished.reversed(), []) : ([], cycle)
}

let steps = ["fetch", "resolve", "compile", "link", "test", "deploy"]
var rules: [String: [String]] = [
    "fetch": ["resolve"], "resolve": ["compile"], "compile": ["link"],
    "link": ["test"], "test": ["deploy"],
]
print(dfsOrder(steps, rules).order)

rules["test"]!.insert("compile", at: 0)           // now test must also come before compile
print(dfsOrder(steps, rules).cycle.joined(separator: " → "))
