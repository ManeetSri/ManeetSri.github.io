// Generated from src/dsa/content/lessons/graph-traversals/gt-components.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let vertexCount = 10
let edges = [[0, 1], [1, 2], [3, 4], [5, 6], [6, 7], [7, 5], [2, 8]]
var neighbours = Array(repeating: [Int](), count: vertexCount)
for edge in edges {
    neighbours[edge[0]].append(edge[1])
    neighbours[edge[1]].append(edge[0])
}

var component = Array(repeating: -1, count: vertexCount)    // -1: not visited yet
var count = 0
for start in 0..<vertexCount where component[start] == -1 {
    component[start] = count                           // a new piece starts here
    var stack = [start]
    while let vertex = stack.popLast() {
        for next in neighbours[vertex] where component[next] == -1 {
            component[next] = count                     // mark on push
            stack.append(next)
        }
    }
    count += 1
}

print("pieces:", count)
print("labels:", component)
for id in 0..<count {
    print("piece \(id):", component.indices.filter { component[$0] == id })
}
