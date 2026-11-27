// Generated from src/dsa/content/lessons/shortest-paths/sp-problems.mdx. Edit the lesson, then run
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

// Two-way roads [a, b, weight limit in tonnes]. How heavy a lorry can drive from the depot (0) to each town?
let roads = [[0, 1, 8], [0, 2, 3], [1, 2, 6], [1, 3, 2], [2, 3, 5], [3, 4, 7]]
let townCount = 5
var graph: [[(to: Int, limit: Int)]] = Array(repeating: [], count: townCount)
for road in roads {
    graph[road[0]].append((road[1], road[2]))
    graph[road[1]].append((road[0], road[2]))
}

// The value of a route is its weakest road. Extending a route can never raise it,
// so the "settle the best one first" argument still works: pop the largest load first.
var heaviest = Array(repeating: 0, count: townCount)
heaviest[0] = Int.max                          // no limit at the depot itself
// A max-heap by load; equal loads come out in town order
var heap = Heap<(load: Int, town: Int)>(areInIncreasingOrder: { $0.load != $1.load ? $0.load > $1.load : $0.town < $1.town })
heap.insert((Int.max, 0))
while let (load, town) = heap.pop() {
    if load < heaviest[town] { continue }      // stale: a heavier lorry already gets here
    for (next, limit) in graph[town] {
        let candidate = min(load, limit)       // the route's weakest road so far
        if candidate > heaviest[next] {
            heaviest[next] = candidate
            heap.insert((candidate, next))
        }
    }
}
print(Array(heaviest.dropFirst()))
