// Generated from src/dsa/content/lessons/shortest-paths/sp-spfa.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = ["S", "A", "B", "C", "D"]
let edges = [(1, 3, 3), (3, 4, 1), (0, 1, 2), (0, 2, 5), (2, 1, -4)]   // A→C 3, C→D 1, S→A 2, S→B 5, B→A −4
var graph: [[(to: Int, weight: Int)]] = Array(repeating: [], count: names.count)
for (a, b, w) in edges {
    graph[a].append((b, w))
}

let infinity = Int.max / 2
var distance = Array(repeating: infinity, count: names.count)
var inQueue = Array(repeating: false, count: names.count)
distance[0] = 0
var queue = [0]                                // a head index makes popping O(1)
var head = 0
inQueue[0] = true
var examined = 0
while head < queue.count {
    let u = queue[head]
    head += 1
    inQueue[u] = false
    for (v, weight) in graph[u] {
        examined += 1
        if distance[u] + weight < distance[v] {
            distance[v] = distance[u] + weight
            print("from \(names[u]): \(names[v]) improves to \(distance[v])")
            if !inQueue[v] {                   // already waiting? it will use its new distance anyway
                queue.append(v)
                inQueue[v] = true
            }
        }
    }
}
print(zip(names, distance).map { "\($0) \($1)" }.joined(separator: ", "))
print("edges examined:", examined)
