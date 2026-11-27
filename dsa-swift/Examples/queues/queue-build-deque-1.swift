// Generated from src/dsa/content/lessons/queues/queue-build-deque.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Deque<Element> {
    private var slots: [Element?] = []
    private var head = 0                     // the slot of the front element
    private(set) var count = 0

    // The slot holding position `offset` from the front
    private func slot(_ offset: Int) -> Int {
        (head + offset) % slots.count
    }

    // Doubles the slots, copying the elements across in order so the front lands in slot 0
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
        head = (head - 1 + slots.count) % slots.count    // one step back, wrapping
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

    var picture: String {
        let cells = slots.map { slot in slot.map { "\($0)" } ?? "_" }
        return cells.joined(separator: " ") + "   head \(head), count \(count)"
    }
}

var deque = Deque<Int>()
deque.append(1)
deque.append(2)
print(deque.picture)
deque.prepend(0)                 // the front wraps round to the last slot
print(deque.picture)
deque.prepend(-1)                // now every slot is in use
print(deque.picture)
deque.append(3)                  // full: grow to 8 slots, in order, then append
print(deque.picture)
print(deque.popFirst() ?? 99, deque.popLast() ?? 99)
print(deque.picture)
