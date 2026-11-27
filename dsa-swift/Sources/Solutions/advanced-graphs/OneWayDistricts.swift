// Reference solution: Count one-way districts. A district is a strongly connected component, so this
// is Tarjan's algorithm: one DFS that gives every junction a discovery index and a low-link, and keeps
// the junctions of unfinished districts on a stack. A junction whose low-link equals its own index is
// the first junction of a district, and everything above it on the stack belongs to that district.
// The DFS uses an explicit stack of (junction, next road) frames instead of recursion, so a chain of
// 100,000 junctions can't overflow the call stack. O(V + E) time and space.

public enum OneWayDistricts {
    public static func count(_ n: Int, _ roads: [[Int]]) -> Int {
        var adjacency = [[Int]](repeating: [], count: n)
        for road in roads {
            adjacency[road[0]].append(road[1])
        }

        var index = [Int](repeating: -1, count: n)     // discovery order; -1 means not visited yet
        var low = [Int](repeating: 0, count: n)
        var onStack = [Bool](repeating: false, count: n)
        var stack: [Int] = []
        var nextIndex = 0
        var districts = 0
        var frames: [(junction: Int, next: Int)] = []  // the DFS "call stack"

        for start in 0..<n where index[start] == -1 {
            index[start] = nextIndex
            low[start] = nextIndex
            nextIndex += 1
            stack.append(start)
            onStack[start] = true
            frames.append((start, 0))

            while let frame = frames.last {
                let v = frame.junction
                if frame.next < adjacency[v].count {
                    frames[frames.count - 1].next += 1
                    let w = adjacency[v][frame.next]
                    if index[w] == -1 {
                        // A tree edge: "call" the DFS on w
                        index[w] = nextIndex
                        low[w] = nextIndex
                        nextIndex += 1
                        stack.append(w)
                        onStack[w] = true
                        frames.append((w, 0))
                    } else if onStack[w] {
                        low[v] = min(low[v], index[w])
                    }
                } else {
                    // Every road out of v is done: "return" to its parent
                    frames.removeLast()
                    if let parent = frames.last?.junction {
                        low[parent] = min(low[parent], low[v])
                    }
                    if low[v] == index[v] {
                        districts += 1
                        while true {
                            let w = stack.removeLast()
                            onStack[w] = false
                            if w == v { break }
                        }
                    }
                }
            }
        }
        return districts
    }
}
