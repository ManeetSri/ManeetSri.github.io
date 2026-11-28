// Generated from src/dsa/content/lessons/mst/mst-prim.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The heap from "Build a generic Heap<T>", compacted
struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    var count: Int { items.count }

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
            if first == parent { return top }
            items.swapAt(parent, first)
            parent = first
        }
    }
}

let names = ["A", "B", "C", "D", "E", "F"]
let edges = [(0, 1, 4), (0, 2, 2), (1, 2, 1), (1, 3, 5), (2, 4, 10), (3, 4, 2), (3, 5, 6), (4, 5, 3)]
var neighbours = Array(repeating: [(to: Int, weight: Int)](), count: names.count)
for (a, b, weight) in edges {
    neighbours[a].append((b, weight))
    neighbours[b].append((a, weight))
}

/// The MST's total weight, growing one tree from start, or nil if some vertex can't be reached
func prim(from start: Int) -> Int? {
    var inTree = Array(repeating: false, count: names.count)
    var candidates = Heap<(weight: Int, from: Int, to: Int)>(areInIncreasingOrder: { $0.weight < $1.weight })
    candidates.insert((0, start, start))
    var total = 0
    var treeSize = 0
    while let edge = candidates.pop() {
        if inTree[edge.to] {
            print("pop \(names[edge.from])\(names[edge.to]) \(edge.weight): stale, \(names[edge.to]) is already in the tree")
            continue
        }
        inTree[edge.to] = true
        total += edge.weight
        treeSize += 1
        print(edge.to == start ? "start at \(names[start])"
              : "pop \(names[edge.from])\(names[edge.to]) \(edge.weight): add \(names[edge.to])")
        for next in neighbours[edge.to] where !inTree[next.to] {
            candidates.insert((next.weight, edge.to, next.to))
        }
    }
    return treeSize == names.count ? total : nil
}

print("total weight:", prim(from: 0)!)
