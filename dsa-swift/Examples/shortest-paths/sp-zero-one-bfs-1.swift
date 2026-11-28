// Generated from src/dsa/content/lessons/shortest-paths/sp-zero-one-bfs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A deque that is popped only from the front: amortised O(1) for all three operations
struct Deque<Element> {
    private var front: [Element] = []         // stored reversed, so its last element is first in line
    private var back: [Element] = []
    var isEmpty: Bool { front.isEmpty && back.isEmpty }
    var contents: [Element] { front.reversed() + back }

    mutating func pushFront(_ element: Element) { front.append(element) }
    mutating func pushBack(_ element: Element) { back.append(element) }
    mutating func popFront() -> Element? {
        if front.isEmpty {
            front = back.reversed()
            back.removeAll()
        }
        return front.popLast()
    }
}

let names = ["S", "A", "B", "C", "T"]
// Directed edges with weight 0 or 1, as graph[from] = [(to, weight)]
let graph: [[(to: Int, weight: Int)]] = [
    [(1, 1), (2, 0)],                          // S→A 1, S→B 0
    [(4, 0)],                                  // A→T 0
    [(1, 0), (3, 1)],                          // B→A 0, B→C 1
    [(4, 0)],                                  // C→T 0
    [],
]

var distance = Array(repeating: Int.max, count: names.count)
distance[0] = 0
var deque = Deque<(vertex: Int, distance: Int)>()
deque.pushBack((0, 0))
while let (vertex, d) = deque.popFront() {
    if d > distance[vertex] {
        print("pop \(names[vertex]):\(d), stale, skip")
        continue
    }
    print("pop \(names[vertex]):\(d)")
    for (next, weight) in graph[vertex] where d + weight < distance[next] {
        distance[next] = d + weight
        if weight == 0 {
            deque.pushFront((next, d))             // as close as the current vertex: front
        } else {
            deque.pushBack((next, d + 1))          // one further: back
        }
    }
    print("   deque:", deque.contents.map { "\(names[$0.vertex]):\($0.distance)" })
}
print(zip(names, distance).map { "\($0) \($1)" })
