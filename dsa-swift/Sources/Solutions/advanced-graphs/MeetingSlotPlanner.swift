// Reference solution: Morning or afternoon. 2-SAT: meeting x in the morning is node 2x and in the
// afternoon node 2x + 1, so a literal's negation is node ^ 1. A rule "a or b" becomes two implications,
// not a → b and not b → a. Tarjan's algorithm finds the strongly connected components, numbering them
// in reverse topological order (sinks first). If a meeting's two nodes share a component, each implies
// the other: impossible. Otherwise pick the literal whose component comes later in topological order,
// which is the smaller Tarjan number. The DFS uses an explicit stack, so long implication chains are
// safe. O(n + rules) time and space.

public enum MeetingSlotPlanner {
    public static func plan(_ meetings: Int, _ rules: [[Int]]) -> [Bool]? {
        let nodes = 2 * meetings
        func node(_ code: Int) -> Int { code >= 0 ? 2 * code : 2 * ~code + 1 }

        var implies = [[Int]](repeating: [], count: nodes)
        for rule in rules {
            let a = node(rule[0])
            let b = node(rule[1])
            implies[a ^ 1].append(b)                   // not a → b
            implies[b ^ 1].append(a)                   // not b → a
        }

        // Iterative Tarjan; component numbers come out in reverse topological order
        var index = [Int](repeating: -1, count: nodes)
        var low = [Int](repeating: 0, count: nodes)
        var component = [Int](repeating: -1, count: nodes)
        var onStack = [Bool](repeating: false, count: nodes)
        var stack: [Int] = []
        var frames: [(node: Int, next: Int)] = []
        var nextIndex = 0
        var components = 0

        for start in 0..<nodes where index[start] == -1 {
            index[start] = nextIndex
            low[start] = nextIndex
            nextIndex += 1
            stack.append(start)
            onStack[start] = true
            frames.append((start, 0))
            while let frame = frames.last {
                let v = frame.node
                if frame.next < implies[v].count {
                    frames[frames.count - 1].next += 1
                    let w = implies[v][frame.next]
                    if index[w] == -1 {
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
                    frames.removeLast()
                    if let parent = frames.last?.node {
                        low[parent] = min(low[parent], low[v])
                    }
                    if low[v] == index[v] {
                        while true {
                            let w = stack.removeLast()
                            onStack[w] = false
                            component[w] = components
                            if w == v { break }
                        }
                        components += 1
                    }
                }
            }
        }

        var morning = [Bool](repeating: false, count: meetings)
        for x in 0..<meetings {
            if component[2 * x] == component[2 * x + 1] { return nil }
            morning[x] = component[2 * x] < component[2 * x + 1]
        }
        return morning
    }
}
