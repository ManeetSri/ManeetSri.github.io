// Generated from src/dsa/content/lessons/topo-sort/topo-kahn.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A compact min-heap of Ints, as in "Build a generic Heap<T>"
struct MinHeap {
    private var items: [Int] = []
    var isEmpty: Bool { items.isEmpty }

    mutating func insert(_ value: Int) {
        items.append(value)
        var child = items.count - 1
        while child > 0 && items[child] < items[(child - 1) / 2] {
            items.swapAt(child, (child - 1) / 2)
            child = (child - 1) / 2
        }
    }

    mutating func pop() -> Int? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        var parent = 0
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var smallest = parent
            if left < items.count && items[left] < items[smallest] { smallest = left }
            if right < items.count && items[right] < items[smallest] { smallest = right }
            if smallest == parent { break }
            items.swapAt(parent, smallest)
            parent = smallest
        }
        return top
    }
}

let n = 6
let edges = [[5, 2], [4, 2], [4, 0], [2, 3], [3, 1]]
var after = Array(repeating: [Int](), count: n)
var inDegree = Array(repeating: 0, count: n)
for edge in edges {
    after[edge[0]].append(edge[1])
    inDegree[edge[1]] += 1
}

// First in, first out
var waiting = inDegree
var queue = (0..<n).filter { waiting[$0] == 0 }
var head = 0
while head < queue.count {
    let vertex = queue[head]
    head += 1
    for next in after[vertex] {
        waiting[next] -= 1
        if waiting[next] == 0 { queue.append(next) }
    }
}
print("queue:   ", queue)

// Smallest ready vertex first
waiting = inDegree
var ready = MinHeap()
for vertex in 0..<n where waiting[vertex] == 0 {
    ready.insert(vertex)
}
var smallestFirst: [Int] = []
while let vertex = ready.pop() {
    smallestFirst.append(vertex)
    for next in after[vertex] {
        waiting[next] -= 1
        if waiting[next] == 0 { ready.insert(next) }
    }
}
print("min-heap:", smallestFirst)
