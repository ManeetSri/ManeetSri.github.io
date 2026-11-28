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

// Flights [from, to, price]. The cheap way into city 2 uses an extra stop.
let flights = [[0, 1, 1], [1, 2, 1], [0, 2, 5], [2, 3, 1]]
let cityCount = 4

/// The trap: Dijkstra that settles each city once, by price, and refuses paths with too many flights
func naiveCheapest(from source: Int, to target: Int, maxStops: Int) -> Int {
    var settled = Array(repeating: false, count: cityCount)
    var heap = Heap<(price: Int, city: Int, flights: Int)>(areInIncreasingOrder: { ($0.price, $0.city) < ($1.price, $1.city) })
    heap.insert((0, source, 0))
    while let (price, city, used) = heap.pop() {
        if settled[city] { continue }
        settled[city] = true
        if city == target { return price }
        guard used <= maxStops else { continue }   // used + 1 flights would be too many
        for flight in flights where flight[0] == city {   // scanning the list keeps the example short
            heap.insert((price + flight[2], flight[1], used + 1))
        }
    }
    return -1
}

/// Bellman–Ford with a copy per round: maxStops + 1 rounds, one more flight each round
func roundsCheapest(from source: Int, to target: Int, maxStops: Int) -> Int {
    var price = Array(repeating: Int.max, count: cityCount)
    price[source] = 0
    for _ in 0...maxStops {
        let before = price
        for flight in flights where before[flight[0]] != Int.max {
            price[flight[1]] = min(price[flight[1]], before[flight[0]] + flight[2])
        }
    }
    return price[target] == Int.max ? -1 : price[target]
}

for stops in 0...2 {
    print("at most \(stops) stop(s): naive \(naiveCheapest(from: 0, to: 3, maxStops: stops)), rounds \(roundsCheapest(from: 0, to: 3, maxStops: stops))")
}
