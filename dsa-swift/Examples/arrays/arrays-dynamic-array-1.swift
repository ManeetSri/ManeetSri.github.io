// Generated from src/dsa/content/lessons/arrays/arrays-dynamic-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct DynamicArray<Element> {
    private var buffer: [Element?] = []
    private(set) var count = 0

    var capacity: Int {
        buffer.count
    }

    mutating func append(_ element: Element) {
        if count == capacity {
            var bigger = [Element?](repeating: nil, count: max(1, capacity * 2))
            for position in 0..<count {
                bigger[position] = buffer[position]
            }
            buffer = bigger
        }
        buffer[count] = element
        count += 1
    }

    mutating func removeLast() -> Element {
        precondition(count > 0, "Can't remove from an empty array")
        count -= 1
        let removed = buffer[count]!
        buffer[count] = nil
        return removed
    }
}

var numbers = DynamicArray<Int>()
for value in 1...5 {
    numbers.append(value)
    print("appended \(value): count \(numbers.count), capacity \(numbers.capacity)")
}
print("removed", numbers.removeLast())
print("count \(numbers.count), capacity \(numbers.capacity)")
