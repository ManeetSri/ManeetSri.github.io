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

let names = ["A", "B", "C", "D", "E", "F"]
var graph: [[(to: Int, weight: Int)]] = Array(repeating: [], count: names.count)
for (a, b, w) in [(0, 1, 4), (0, 2, 2), (1, 2, 1), (1, 3, 5), (2, 4, 10), (3, 4, 2), (3, 5, 6), (4, 5, 3)] {
    graph[a].append((b, w))
    graph[b].append((a, w))                    // undirected
}

func dijkstra(from source: Int) -> [Int] {
    let infinity = Int.max / 2
    var distance = Array(repeating: infinity, count: graph.count)
    distance[source] = 0
    // (distance, vertex), closest first; ties go to the smaller vertex number
    var heap = Heap<(distance: Int, vertex: Int)>(areInIncreasingOrder: { ($0.distance, $0.vertex) < ($1.distance, $1.vertex) })
    heap.insert((0, source))
    while let (d, u) = heap.pop() {
        if d > distance[u] {                   // stale: u was already settled with a smaller distance
            print("skip \(names[u]):\(d), stale")
            continue
        }
        print("settle \(names[u]) at \(d)")
        for (v, weight) in graph[u] where d + weight < distance[v] {
            distance[v] = d + weight           // relax
            heap.insert((distance[v], v))      // the old entry for v, if any, stays behind as stale
        }
    }
    return distance
}

print(dijkstra(from: 0))
