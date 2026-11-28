// Generated from src/dsa/content/lessons/graph-traversals/gt-bfs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let edges = [[0, 1], [0, 2], [1, 3], [2, 3], [2, 4], [3, 5], [4, 5], [5, 6], [6, 7]]
var neighbours = Array(repeating: [Int](), count: 8)
for edge in edges {
    neighbours[edge[0]].append(edge[1])
    neighbours[edge[1]].append(edge[0])
}

var seen = Array(repeating: false, count: 8)
seen[0] = true
var queue = [0]
var head = 0
var distance = 0
while head < queue.count {
    let levelEnd = queue.count                          // everything queued so far is this level
    print("distance \(distance):", queue[head..<levelEnd].sorted())
    while head < levelEnd {
        let vertex = queue[head]
        head += 1
        for next in neighbours[vertex] where !seen[next] {
            seen[next] = true
            queue.append(next)
        }
    }
    distance += 1
}
