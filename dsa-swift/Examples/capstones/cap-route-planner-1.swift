// Generated from src/dsa/content/lessons/capstones/cap-route-planner.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The heap from "Build a generic Heap<T>", cut down to insert and pop
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
            let left = 2 * parent + 1, right = left + 1
            var first = parent
            if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
            if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
            if first == parent { return top }
            items.swapAt(parent, first)
            parent = first
        }
    }
}

/// A place, in metres east (x) and north (y) of the town hall
struct Place {
    let name: String
    let x: Double
    let y: Double
}

let places = [
    Place(name: "Home", x: 0, y: 300), Place(name: "Westgate", x: -200, y: 300), Place(name: "Farm", x: -100, y: 0),
    Place(name: "School", x: 100, y: 100), Place(name: "Bakery", x: 100, y: 500), Place(name: "Park", x: 300, y: 300),
    Place(name: "Library", x: 200, y: 600), Place(name: "Market", x: 400, y: 500), Place(name: "Station", x: 500, y: 0),
    Place(name: "Bridge", x: 500, y: 300), Place(name: "Museum", x: 700, y: 500), Place(name: "Hospital", x: 700, y: 100),
    Place(name: "Harbour", x: 900, y: 300), Place(name: "Lake", x: -300, y: 500), Place(name: "Mill", x: -400, y: 100),
]
// Road lengths in metres. Roads bend, so each is at least the straight-line distance between its ends.
let roads = [
    ("Home", "Westgate", 221), ("Westgate", "Farm", 380), ("Home", "School", 246), ("Home", "Bakery", 258),
    ("Home", "Park", 315), ("School", "Station", 454), ("Bakery", "Library", 156), ("Library", "Market", 246),
    ("Park", "Market", 269), ("Park", "Bridge", 221), ("Bridge", "Museum", 340), ("Bridge", "Hospital", 326),
    ("Station", "Hospital", 235), ("Market", "Museum", 330), ("Museum", "Harbour", 354), ("Hospital", "Harbour", 340),
    ("Farm", "School", 246), ("Bridge", "Harbour", 700), ("Westgate", "Lake", 246), ("Westgate", "Mill", 326),
    ("Mill", "Farm", 348),
]

let id = Dictionary(uniqueKeysWithValues: places.enumerated().map { ($1.name, $0) })
var neighbours = Array(repeating: [(to: Int, metres: Int)](), count: places.count)
for (a, b, metres) in roads {
    neighbours[id[a]!].append((id[b]!, metres))
    neighbours[id[b]!].append((id[a]!, metres))
}

/// The straight-line distance, rounded down: never more than the length of any road route
func straightLine(_ a: Int, _ b: Int) -> Int {
    let dx = places[a].x - places[b].x, dy = places[a].y - places[b].y
    return Int((dx * dx + dy * dy).squareRoot())
}

/// Weight 0 is Dijkstra, 1 is A*, more than 1 trusts the estimate too much
func route(from start: String, to goal: String, heuristicWeight: Int) -> (metres: Int, path: [String], expanded: [String]) {
    let source = id[start]!, target = id[goal]!
    var best = Array(repeating: Int.max, count: places.count)
    var previous = Array(repeating: -1, count: places.count)
    var expanded: [String] = []
    // Entries are (f, h, place): smallest f = g + weight × h first, then the one that looks closer
    var open = Heap<(f: Int, h: Int, place: Int)>(areInIncreasingOrder: { ($0.f, $0.h, $0.place) < ($1.f, $1.h, $1.place) })
    best[source] = 0
    open.insert((heuristicWeight * straightLine(source, target), straightLine(source, target), source))
    while let entry = open.pop() {
        let g = entry.f - heuristicWeight * entry.h
        if g > best[entry.place] { continue }                  // a stale entry: a shorter way was found
        expanded.append(places[entry.place].name)
        if entry.place == target { break }
        for (next, metres) in neighbours[entry.place] where g + metres < best[next] {
            best[next] = g + metres
            previous[next] = entry.place
            let h = straightLine(next, target)
            open.insert((g + metres + heuristicWeight * h, h, next))
        }
    }
    var path: [String] = []
    var step = target
    while step != -1 {
        path.append(places[step].name)
        step = previous[step]
    }
    return (best[target], path.reversed(), expanded)
}

let goal = id["Harbour"]!
let consistent = roads.allSatisfy { a, b, metres in
    straightLine(id[a]!, goal) <= metres + straightLine(id[b]!, goal) && straightLine(id[b]!, goal) <= metres + straightLine(id[a]!, goal)
}
print("heuristic consistent on all \(roads.count) roads:", consistent)

let dijkstra = route(from: "Home", to: "Harbour", heuristicWeight: 0)
let aStar = route(from: "Home", to: "Harbour", heuristicWeight: 1)
let greedy = route(from: "Home", to: "Harbour", heuristicWeight: 3)
for (name, result) in [("Dijkstra", dijkstra), ("A*", aStar), ("A* with 3h", greedy)] {
    print("\(name): \(result.metres) m via \(result.path.joined(separator: " → ")), expanded \(result.expanded.count)")
}
print("A* never expanded:", Set(dijkstra.expanded).subtracting(aStar.expanded).sorted().joined(separator: ", "))
