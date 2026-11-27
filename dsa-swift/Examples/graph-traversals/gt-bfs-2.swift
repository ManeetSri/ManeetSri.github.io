// Generated from src/dsa/content/lessons/graph-traversals/gt-bfs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// How many times does BFS enqueue something? It depends on when vertices are marked.
func enqueueCount(_ neighbours: [[Int]], markWhenEnqueued: Bool) -> Int {
    var seen = Array(repeating: false, count: neighbours.count)
    var queue = [0]
    var head = 0
    if markWhenEnqueued { seen[0] = true }
    while head < queue.count {
        let vertex = queue[head]
        head += 1
        if !markWhenEnqueued {
            if seen[vertex] { continue }                 // a duplicate: skip it
            seen[vertex] = true
        }
        for next in neighbours[vertex] where !seen[next] {
            if markWhenEnqueued { seen[next] = true }
            queue.append(next)
        }
    }
    return queue.count
}

// A 100 × 100 grid: each cell joined to the cells above, below, left and right
let size = 100
let grid = (0..<(size * size)).map { cell -> [Int] in
    let (row, column) = (cell / size, cell % size)
    var result: [Int] = []
    if row > 0 { result.append(cell - size) }
    if row < size - 1 { result.append(cell + size) }
    if column > 0 { result.append(cell - 1) }
    if column < size - 1 { result.append(cell + 1) }
    return result
}
// 1,000 vertices, every one joined to every other
let complete = (0..<1_000).map { vertex in (0..<1_000).filter { $0 != vertex } }

for (name, graph) in [("grid", grid), ("complete", complete)] {
    let early = enqueueCount(graph, markWhenEnqueued: true)
    let late = enqueueCount(graph, markWhenEnqueued: false)
    print("\(name): \(graph.count) vertices, mark on enqueue \(early), mark on dequeue \(late)")
}
