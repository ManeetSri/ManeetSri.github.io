// Generated from src/dsa/content/lessons/queues/queue-ring-buffer.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct IntRing {
    private var slots: [Int?]
    private var head = 0                 // the slot holding the oldest value
    private(set) var count = 0

    init(capacity: Int) {
        slots = Array(repeating: nil, count: capacity)
    }

    var capacity: Int { slots.count }
    var isFull: Bool { count == capacity }

    mutating func enqueue(_ value: Int) -> Bool {
        guard !isFull else { return false }          // full: refuse
        slots[(head + count) % capacity] = value     // the slot right after the back
        count += 1
        return true
    }

    mutating func dequeue() -> Int? {
        guard count > 0 else { return nil }
        let value = slots[head]
        slots[head] = nil
        head = (head + 1) % capacity                 // wraps from the last slot to 0
        count -= 1
        return value
    }

    var picture: String {
        let cells = slots.map { slot in slot.map { String($0) } ?? "_" }
        return cells.joined(separator: " ") + "   head \(head), count \(count)"
    }
}

var ring = IntRing(capacity: 4)
for value in [1, 2, 3] { _ = ring.enqueue(value) }
print(ring.picture)
_ = ring.dequeue()
_ = ring.dequeue()
print(ring.picture)
for value in [4, 5, 6] { _ = ring.enqueue(value) }
print(ring.picture)
print("enqueue 7:", ring.enqueue(7))
print(ring.dequeue() ?? 0, ring.dequeue() ?? 0)
print(ring.picture)
