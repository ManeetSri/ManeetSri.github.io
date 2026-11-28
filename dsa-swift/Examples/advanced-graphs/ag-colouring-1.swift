// Generated from src/dsa/content/lessons/advanced-graphs/ag-colouring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Greedy colouring: each vertex, in the given order, takes the smallest colour its coloured neighbours don't use
func greedyColouring(_ n: Int, _ edges: [[Int]], order: [Int]) -> [Int] {
    var neighbours = [[Int]](repeating: [], count: n)
    for edge in edges {
        neighbours[edge[0]].append(edge[1])
        neighbours[edge[1]].append(edge[0])
    }
    var colour = [Int](repeating: -1, count: n)
    for v in order {
        let taken = Set(neighbours[v].map { colour[$0] })
        var c = 0
        while taken.contains(c) { c += 1 }
        colour[v] = c
    }
    return colour
}

// Four left vertices 0–3 and four right vertices 4–7; i is joined to 4 + j whenever i ≠ j
var edges: [[Int]] = []
for i in 0..<4 {
    for j in 0..<4 where i != j {
        edges.append([i, 4 + j])
    }
}
let leftThenRight = greedyColouring(8, edges, order: [0, 1, 2, 3, 4, 5, 6, 7])
let alternating = greedyColouring(8, edges, order: [0, 4, 1, 5, 2, 6, 3, 7])
print("left side first:", leftThenRight, "uses", leftThenRight.max()! + 1, "colours")
print("alternating:    ", alternating, "uses", alternating.max()! + 1, "colours")
