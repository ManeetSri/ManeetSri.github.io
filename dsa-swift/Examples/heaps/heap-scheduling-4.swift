// Generated from src/dsa/content/lessons/heaps/heap-scheduling.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The heap from "Build a generic Heap<T>", compacted, plus replaceTop
struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    var count: Int { items.count }
    var isEmpty: Bool { items.isEmpty }
    func peek() -> Element? { items.first }

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
        siftDownFromTop()
        return top
    }

    /// Replaces the top (the heap must not be empty) with one sift down
    mutating func replaceTop(with element: Element) {
        items[0] = element
        siftDownFromTop()
    }

    private mutating func siftDownFromTop() {
        var parent = 0
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var first = parent
            if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
            if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
            if first == parent { return }
            items.swapAt(parent, first)
            parent = first
        }
    }
}

// Take up to k projects; each needs capital >= its requirement (not spent) and adds its profit
func bestCapital(start: Int, k: Int, projects: [(name: String, requirement: Int, profit: Int)]) -> Int {
    let byRequirement = projects.sorted { $0.requirement < $1.requirement }
    var affordable = Heap<(name: String, requirement: Int, profit: Int)>(areInIncreasingOrder: { $0.profit > $1.profit })
    var capital = start
    var next = 0
    for _ in 0..<k {
        while next < byRequirement.count && byRequirement[next].requirement <= capital {
            affordable.insert(byRequirement[next])          // newly affordable
            next += 1
        }
        guard let best = affordable.pop() else { break }  // nothing affordable: stop early
        capital += best.profit
        print("take \(best.name) (needs \(best.requirement), earns \(best.profit)): capital \(capital)")
    }
    return capital
}

let projects = [
    (name: "logo", requirement: 0, profit: 2),
    (name: "website", requirement: 3, profit: 10),
    (name: "poster", requirement: 0, profit: 1),
    (name: "app", requirement: 12, profit: 30),
    (name: "video", requirement: 2, profit: 5),
]
print(bestCapital(start: 1, k: 3, projects: projects))
