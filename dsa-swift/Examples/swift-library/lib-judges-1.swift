// Generated from src/dsa/content/lessons/swift-library/lib-judges.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// "In production I'd use Deque from swift-collections. Here's a queue with a head index:
// enqueue and dequeue are O(1), and the array is never shifted."
struct Queue<Element> {
    private var items: [Element] = []
    private var head = 0

    var isEmpty: Bool { head == items.count }

    mutating func enqueue(_ item: Element) {
        items.append(item)
    }

    mutating func dequeue() -> Element? {
        guard head < items.count else { return nil }
        defer { head += 1 }
        return items[head]
    }
}

func distances(from start: Int, in graph: [[Int]]) -> [Int] {
    var distance = Array(repeating: -1, count: graph.count)
    distance[start] = 0
    var queue = Queue<Int>()
    queue.enqueue(start)
    while let node = queue.dequeue() {
        for next in graph[node] where distance[next] == -1 {
            distance[next] = distance[node] + 1
            queue.enqueue(next)
        }
    }
    return distance
}

let graph = [[1, 2], [0, 3], [0, 3], [1, 2, 4], [3], []]
print(distances(from: 0, in: graph))
