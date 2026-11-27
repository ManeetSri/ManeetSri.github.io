// Generated from src/dsa/content/lessons/shortest-paths/sp-dijkstra.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The heap from "Build a generic Heap<T>", cut down to what Dijkstra needs
struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    mutating func insert(_ element: Element) {
        items.append(element)
        var child = items.count - 1
        while child > 0 && areInIncreasingOrder(items[child], items[(child - 1) / 2]) {
            items.swapAt(child, (child - 1) / 2)
            child = (child - 1) / 2
        }
    }

    mutating func pop() -> Element? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        var parent = 0
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var first = parent
            if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
            if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
            if first == parent { break }
            items.swapAt(parent, first)
            parent = first
        }
        return top
    }
}

let names = ["S", "A", "B", "C", "D"]
let edges = [(1, 3, 3), (3, 4, 1), (0, 1, 2), (0, 2, 5), (2, 1, -4)]   // A→C 3, C→D 1, S→A 2, S→B 5, B→A −4
var graph: [[(to: Int, weight: Int)]] = Array(repeating: [], count: names.count)
for (a, b, w) in edges {
    graph[a].append((b, w))                    // directed
}

/// Lazy Dijkstra from S. With `target`, it stops as soon as the target is popped.
func dijkstra(stoppingAt target: Int? = nil) -> (distance: [Int], processed: Int) {
    var distance = Array(repeating: Int.max / 2, count: names.count)
    distance[0] = 0
    var processed = 0
    var heap = Heap<(distance: Int, vertex: Int)>(areInIncreasingOrder: { ($0.distance, $0.vertex) < ($1.distance, $1.vertex) })
    heap.insert((0, 0))
    while let (d, u) = heap.pop() {
        if d > distance[u] { continue }
        if u == target { break }
        processed += 1
        for (v, weight) in graph[u] where d + weight < distance[v] {
            distance[v] = d + weight
            heap.insert((distance[v], v))
        }
    }
    return (distance, processed)
}

// The truth, by relaxing every edge until nothing changes
var truth = Array(repeating: Int.max / 2, count: names.count)
truth[0] = 0
for _ in 1..<names.count {
    for (a, b, w) in edges where truth[a] < Int.max / 2 && truth[a] + w < truth[b] {
        truth[b] = truth[a] + w
    }
}

print("true distances:      ", truth)
print("Dijkstra, stop at A:  A =", dijkstra(stoppingAt: 1).distance[1])
let full = dijkstra()
print("Dijkstra, no stop:   ", full.distance, "after processing", full.processed, "times for", names.count, "vertices")
