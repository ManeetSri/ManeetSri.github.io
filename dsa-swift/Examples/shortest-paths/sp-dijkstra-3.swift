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

// Junctions 0...5 joined by two-way roads (a, b, minutes). Fire stations stand at junctions 0 and 5.
let roads = [(0, 1, 4), (1, 2, 3), (2, 3, 2), (3, 4, 6), (4, 5, 1), (1, 4, 9), (2, 5, 8)]
var graph: [[(to: Int, minutes: Int)]] = Array(repeating: [], count: 6)
for (a, b, w) in roads {
    graph[a].append((b, w))
    graph[b].append((a, w))
}

let stations = [0, 5]
var minutes = Array(repeating: Int.max, count: 6)
var station = Array(repeating: -1, count: 6)     // which station's engine gets there first
var heap = Heap<(minutes: Int, junction: Int)>(areInIncreasingOrder: { ($0.minutes, $0.junction) < ($1.minutes, $1.junction) })
for source in stations {                         // every source starts in the heap at 0
    minutes[source] = 0
    station[source] = source
    heap.insert((0, source))
}
while let (time, junction) = heap.pop() {
    if time > minutes[junction] { continue }
    for (next, w) in graph[junction] where time + w < minutes[next] {
        minutes[next] = time + w
        station[next] = station[junction]        // reached through this station's region
        heap.insert((minutes[next], next))
    }
}
for junction in 0..<6 {
    print("junction \(junction): \(minutes[junction]) min from station \(station[junction])")
}
