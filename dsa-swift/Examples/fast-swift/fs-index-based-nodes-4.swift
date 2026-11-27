// Generated from src/dsa/content/lessons/fast-swift/fs-index-based-nodes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var head = [Int](repeating: -1, count: 4)   // the first edge out of each node, or -1
var target: [Int] = []                       // where each edge goes
var nextEdge: [Int] = []                     // the next edge out of the same node, or -1

func addEdge(_ from: Int, _ to: Int) {
    target.append(to)
    nextEdge.append(head[from])
    head[from] = target.count - 1
}

for (from, to) in [(0, 1), (0, 2), (1, 3), (0, 3)] {
    addEdge(from, to)
}

var edge = head[0]
var neighbours: [Int] = []
while edge != -1 {
    neighbours.append(target[edge])
    edge = nextEdge[edge]
}
print(neighbours)
