// Generated from src/dsa/content/lessons/graph-traversals/gt-bipartite.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A colour (0 or 1) for every vertex with every edge joining different colours, or nil if impossible
func twoColouring(_ vertexCount: Int, _ edges: [[Int]]) -> [Int]? {
    var neighbours = Array(repeating: [Int](), count: vertexCount)
    for edge in edges {
        neighbours[edge[0]].append(edge[1])
        neighbours[edge[1]].append(edge[0])
    }
    var colour = Array(repeating: -1, count: vertexCount)   // -1: not coloured yet
    for start in 0..<vertexCount where colour[start] == -1 {  // one BFS per piece of the graph
        colour[start] = 0
        var queue = [start]
        var head = 0
        while head < queue.count {
            let vertex = queue[head]
            head += 1
            for next in neighbours[vertex] {
                if colour[next] == -1 {
                    colour[next] = 1 - colour[vertex]    // the opposite colour
                    queue.append(next)
                } else if colour[next] == colour[vertex] {
                    return nil                          // an edge inside one colour: impossible
                }
            }
        }
    }
    return colour
}

let examples: [(String, Int, [[Int]])] = [
    ("square", 4, [[0, 1], [1, 2], [2, 3], [3, 0]]),
    ("pentagon", 5, [[0, 1], [1, 2], [2, 3], [3, 4], [4, 0]]),
    ("tree", 6, [[0, 1], [0, 2], [1, 3], [1, 4], [2, 5]]),
    ("two pieces", 5, [[0, 1], [2, 3], [3, 4]]),
    ("self-loop", 2, [[0, 1], [1, 1]]),
]
for (name, count, edges) in examples {
    if let colours = twoColouring(count, edges) {
        print(name, colours)
    } else {
        print(name, "is not bipartite")
    }
}
