// Generated from src/dsa/content/lessons/queues/queue-build-deque.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Deque<Element> {
    private var slots: [Element?] = []
    private var head = 0
    private(set) var count = 0

    init() {}

    private func slot(_ offset: Int) -> Int {
        (head + offset) % slots.count
    }

    private mutating func grow() {
        var bigger = [Element?](repeating: nil, count: Swift.max(4, slots.count * 2))
        for offset in 0..<count {
            bigger[offset] = slots[slot(offset)]
        }
        slots = bigger
        head = 0
    }

    mutating func append(_ element: Element) {
        if count == slots.count { grow() }
        slots[slot(count)] = element
        count += 1
    }

    mutating func prepend(_ element: Element) {
        if count == slots.count { grow() }
        head = (head - 1 + slots.count) % slots.count
        slots[head] = element
        count += 1
    }

    mutating func popFirst() -> Element? {
        guard count > 0 else { return nil }
        let element = slots[head]
        slots[head] = nil
        head = slot(1)
        count -= 1
        return element
    }

    mutating func popLast() -> Element? {
        guard count > 0 else { return nil }
        let index = slot(count - 1)
        let element = slots[index]
        slots[index] = nil
        count -= 1
        return element
    }
}

extension Deque: RandomAccessCollection {
    var startIndex: Int { 0 }
    var endIndex: Int { count }

    subscript(position: Int) -> Element {
        precondition(position >= 0 && position < count, "Deque index out of range")
        return slots[slot(position)]!
    }
}

extension Deque: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements {
            append(element)
        }
    }
}

extension Deque: CustomStringConvertible {
    var description: String { "Deque(\(Array(self)))" }
}

// A deterministic stream of pseudo-random choices, so every run does the same operations
var state: UInt64 = 42
func nextChoice(below limit: Int) -> Int {
    state = state &* 6364136223846793005 &+ 1442695040888963407   // &* and &+ wrap instead of overflowing
    return Int(state >> 33) % limit
}

var deque: Deque<Int> = []
var model: [Int] = []
var mismatches = 0
for step in 0..<10_000 {
    switch nextChoice(below: 4) {
    case 0:
        deque.append(step)
        model.append(step)
    case 1:
        deque.prepend(step)
        model.insert(step, at: 0)
    case 2:
        if deque.popFirst() != (model.isEmpty ? nil : model.removeFirst()) { mismatches += 1 }
    default:
        if deque.popLast() != model.popLast() { mismatches += 1 }
    }
    if !deque.elementsEqual(model) { mismatches += 1 }
}
print("10000 operations, \(mismatches) mismatches, \(deque.count) left")

var small: Deque = [2, 3]
small.prepend(1)
print(small, small.first ?? 0, small.last ?? 0, small[1])
print(small.map { $0 * 10 }, Array(small.reversed()), small.contains(3))
