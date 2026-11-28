// Generated from src/dsa/content/lessons/advanced-graphs/ag-scc.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Tarjan's algorithm with an explicit stack of frames instead of recursion
func countComponents(_ n: Int, _ graph: [[Int]]) -> Int {
    var index = [Int](repeating: -1, count: n)
    var low = [Int](repeating: 0, count: n)
    var onStack = [Bool](repeating: false, count: n)
    var stack: [Int] = []
    var frames: [(vertex: Int, next: Int)] = []    // what each recursive call would have remembered
    var nextIndex = 0
    var components = 0

    for start in 0..<n where index[start] == -1 {
        index[start] = nextIndex
        low[start] = nextIndex
        nextIndex += 1
        stack.append(start)
        onStack[start] = true
        frames.append((start, 0))

        while let frame = frames.last {
            let v = frame.vertex
            if frame.next < graph[v].count {
                frames[frames.count - 1].next += 1     // come back to the next edge later
                let w = graph[v][frame.next]
                if index[w] == -1 {                    // the recursive call, as a push
                    index[w] = nextIndex
                    low[w] = nextIndex
                    nextIndex += 1
                    stack.append(w)
                    onStack[w] = true
                    frames.append((w, 0))
                } else if onStack[w] {
                    low[v] = min(low[v], index[w])
                }
            } else {                                   // the return, as a pop
                frames.removeLast()
                if let parent = frames.last?.vertex {
                    low[parent] = min(low[parent], low[v])
                }
                if low[v] == index[v] {
                    components += 1
                    while true {
                        let w = stack.removeLast()
                        onStack[w] = false
                        if w == v { break }
                    }
                }
            }
        }
    }
    return components
}

let n = 200_000
var chain = [[Int]](repeating: [], count: n)
for v in 0..<(n - 1) {
    chain[v].append(v + 1)
}
print("a chain of 200,000:", countComponents(n, chain))
chain[n - 1].append(0)
print("the same chain closed into a ring:", countComponents(n, chain))
let small = [[1, 7], [2, 3], [0, 4], [4], [5], [3, 6], [7], [6]]
print("the lesson's graph:", countComponents(8, small))
