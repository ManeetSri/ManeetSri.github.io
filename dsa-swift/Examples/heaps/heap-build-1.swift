// Generated from src/dsa/content/lessons/heaps/heap-build.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Heap<Element> {
    private var items: [Element] = []
    private let areInIncreasingOrder: (Element, Element) -> Bool

    init(areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }

    init(_ elements: [Element], areInIncreasingOrder: @escaping (Element, Element) -> Bool) {
        self.items = elements
        self.areInIncreasingOrder = areInIncreasingOrder
        for index in stride(from: items.count / 2 - 1, through: 0, by: -1) {
            siftDown(from: index)
        }
    }

    var count: Int { items.count }
    var isEmpty: Bool { items.isEmpty }

    func peek() -> Element? {
        items.first
    }

    mutating func insert(_ element: Element) {
        items.append(element)
        siftUp(from: items.count - 1)
    }

    @discardableResult
    mutating func pop() -> Element? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        siftDown(from: 0)
        return top
    }

    private mutating func siftUp(from index: Int) {
        var child = index
        while child > 0 {
            let parent = (child - 1) / 2
            guard areInIncreasingOrder(items[child], items[parent]) else { return }
            items.swapAt(child, parent)
            child = parent
        }
    }

    private mutating func siftDown(from index: Int) {
        var parent = index
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

extension Heap where Element: Comparable {
    static func minHeap() -> Heap { Heap(areInIncreasingOrder: <) }
    static func maxHeap() -> Heap { Heap(areInIncreasingOrder: >) }
}

// 1. Plain numbers, smallest first
var numbers = Heap<Int>.minHeap()
for value in [42, 7, 19, 3, 25] {
    numbers.insert(value)
}
print(numbers.peek()!, numbers.count)

// 2. Words, longest first, built from an array in O(n)
var words = Heap(["fig", "banana", "kiwi", "apple"], areInIncreasingOrder: { $0.count > $1.count })
print(words.pop()!, words.pop()!)

// 3. Tasks by priority (1 is most urgent), ties broken by arrival order
struct Task {
    let name: String
    let priority: Int
    let arrival: Int
}

var tasks = Heap<Task>(areInIncreasingOrder: { a, b in
    a.priority != b.priority ? a.priority < b.priority : a.arrival < b.arrival
})
let incoming = [("write tests", 2), ("fix crash", 1), ("review PR", 2), ("update docs", 3), ("reply to Sam", 1)]
for (arrival, (name, priority)) in incoming.enumerated() {
    tasks.insert(Task(name: name, priority: priority, arrival: arrival))
}
while let task = tasks.pop() {
    print("P\(task.priority) \(task.name)")
}

// 4. The same priority for everything, with no tie-break: not arrival order
var sameUrgency = Heap<Task>(areInIncreasingOrder: { $0.priority < $1.priority })
for (arrival, name) in ["a", "b", "c"].enumerated() {
    sameUrgency.insert(Task(name: name, priority: 1, arrival: arrival))
}
var order: [String] = []
while let task = sameUrgency.pop() {
    order.append(task.name)
}
print(order)

// 5. Copies are independent
var original = Heap([5, 1, 3], areInIncreasingOrder: <)
var copy = original
copy.insert(0)
original.pop()
print(original.peek()!, copy.peek()!, original.count, copy.count)
