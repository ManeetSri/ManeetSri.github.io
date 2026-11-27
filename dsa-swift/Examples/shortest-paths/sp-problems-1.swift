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

/// How long until a signal sent from `source` reaches every server, or -1 if some never hear it.
/// `links` are directed [from, to, milliseconds].
func timeToReachAll(serverCount n: Int, links: [[Int]], source: Int) -> Int {
    var graph: [[(to: Int, time: Int)]] = Array(repeating: [], count: n)
    for link in links {
        graph[link[0]].append((link[1], link[2]))
    }
    var arrival = Array(repeating: Int.max, count: n)
    arrival[source] = 0
    var heap = Heap<(time: Int, server: Int)>(areInIncreasingOrder: { ($0.time, $0.server) < ($1.time, $1.server) })
    heap.insert((0, source))
    var reached = 0
    var latest = 0
    while let (time, server) = heap.pop() {
        if time > arrival[server] { continue }
        reached += 1
        latest = time                          // popped in time order, so the last one popped is the latest
        for (next, delay) in graph[server] where time + delay < arrival[next] {
            arrival[next] = time + delay
            heap.insert((arrival[next], next))
        }
    }
    return reached == n ? latest : -1
}

let links = [[0, 1, 2], [0, 2, 5], [1, 2, 1], [1, 3, 6], [2, 3, 2], [3, 4, 1], [2, 4, 7]]
print(timeToReachAll(serverCount: 5, links: links, source: 0))
print(timeToReachAll(serverCount: 5, links: links, source: 1))
print(timeToReachAll(serverCount: 5, links: links, source: 3))
