// Generated from src/dsa/content/lessons/graph-traversals/gt-cycles.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Three-colour DFS without recursion. Each frame remembers which neighbour to try next.
/// Returns whether there's a cycle, and the order in which vertices finished.
func explore(_ vertexCount: Int, _ edges: [[Int]]) -> (cycle: Bool, finished: [Int]) {
    var next = Array(repeating: [Int](), count: vertexCount)
    for edge in edges {
        next[edge[0]].append(edge[1])
    }
    var colour = Array(repeating: 0, count: vertexCount)    // 0 white, 1 grey, 2 black
    var finished: [Int] = []
    for root in 0..<vertexCount where colour[root] == 0 {
        colour[root] = 1
        var stack = [(vertex: root, index: 0)]
        while let top = stack.last {
            if top.index == next[top.vertex].count {        // no neighbours left to try
                colour[top.vertex] = 2
                finished.append(top.vertex)
                stack.removeLast()
                continue
            }
            stack[stack.count - 1].index += 1               // next time, try the one after
            let neighbour = next[top.vertex][top.index]
            if colour[neighbour] == 1 { return (true, finished) }
            if colour[neighbour] == 0 {
                colour[neighbour] = 1
                stack.append((neighbour, 0))                // "call" visit(neighbour)
            }
        }
    }
    return (false, finished)
}

let dag = explore(5, [[0, 1], [0, 2], [1, 3], [2, 3], [3, 4]])
print(dag.cycle, "finished:", dag.finished, "reversed:", Array(dag.finished.reversed()))

let count = 100_000
let chain = (0..<(count - 1)).map { [$0, $0 + 1] }
print(explore(count, chain).cycle, explore(count, chain + [[count - 1, 0]]).cycle)
