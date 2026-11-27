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

// Greedy task scheduling: each slot runs the allowed kind with the most tasks left
func schedule(_ tasks: [Character], cooldown: Int) -> String {
    var counts: [Character: Int] = [:]
    for task in tasks {
        counts[task, default: 0] += 1
    }
    // Most tasks left first; ties alphabetical, so the schedule is the same every run
    var ready = Heap<(kind: Character, left: Int)>(areInIncreasingOrder: {
        $0.left != $1.left ? $0.left > $1.left : $0.kind < $1.kind
    })
    for (kind, left) in counts {
        ready.insert((kind, left))
    }
    var cooling: [(kind: Character, left: Int, readyAt: Int)] = []   // in the order they ran
    var slots: [String] = []
    var slot = 0
    while !ready.isEmpty || !cooling.isEmpty {
        while let first = cooling.first, first.readyAt <= slot {
            ready.insert((first.kind, first.left))
            cooling.removeFirst()
        }
        if let task = ready.pop() {
            slots.append(String(task.kind))
            if task.left > 1 {
                cooling.append((task.kind, task.left - 1, slot + cooldown + 1))
            }
        } else {
            slots.append("_")                             // nothing is allowed to run: idle
        }
        slot += 1
    }
    return slots.joined(separator: " ")
}

print(schedule(Array("AAABBC"), cooldown: 2))
print(schedule(Array("AAABBBCCD"), cooldown: 2))
print(schedule(Array("AAAA"), cooldown: 1))
