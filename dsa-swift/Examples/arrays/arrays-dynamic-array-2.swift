// Generated from src/dsa/content/lessons/arrays/arrays-dynamic-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct DynamicArray<Element> {
    private var buffer: [Element?] = []
    private(set) var count = 0

    var capacity: Int {
        buffer.count
    }

    var isEmpty: Bool {
        count == 0
    }

    mutating func append(_ element: Element) {
        growIfFull()
        buffer[count] = element
        count += 1
    }

    mutating func insert(_ element: Element, at index: Int) {
        precondition(index >= 0 && index <= count, "Index out of range")
        growIfFull()
        var position = count
        while position > index {
            buffer[position] = buffer[position - 1]
            position -= 1
        }
        buffer[index] = element
        count += 1
    }

    @discardableResult
    mutating func remove(at index: Int) -> Element {
        precondition(index >= 0 && index < count, "Index out of range")
        let removed = buffer[index]!
        for position in index..<(count - 1) {
            buffer[position] = buffer[position + 1]
        }
        buffer[count - 1] = nil
        count -= 1
        return removed
    }

    @discardableResult
    mutating func removeLast() -> Element {
        precondition(count > 0, "Can't remove from an empty array")
        count -= 1
        let removed = buffer[count]!
        buffer[count] = nil
        return removed
    }

    private mutating func growIfFull() {
        guard count == capacity else { return }
        var bigger = [Element?](repeating: nil, count: Swift.max(1, capacity * 2))
        for position in 0..<count {
            bigger[position] = buffer[position]
        }
        buffer = bigger
    }
}

extension DynamicArray: RandomAccessCollection, MutableCollection {
    var startIndex: Int { 0 }
    var endIndex: Int { count }
    func index(after i: Int) -> Int { i + 1 }
    func index(before i: Int) -> Int { i - 1 }

    subscript(position: Int) -> Element {
        get {
            precondition(position >= 0 && position < count, "Index out of range")
            return buffer[position]!
        }
        set {
            precondition(position >= 0 && position < count, "Index out of range")
            buffer[position] = newValue
        }
    }
}

extension DynamicArray: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements {
            append(element)
        }
    }
}

extension DynamicArray: CustomStringConvertible {
    var description: String {
        "[" + map { "\($0)" }.joined(separator: ", ") + "]"
    }
}

var scores: DynamicArray = [40, 10, 30]
scores.append(20)
scores.insert(50, at: 0)
print(scores, scores.count, scores.capacity)

scores.remove(at: 2)
scores.sort()
print(scores)
print(scores.map { $0 * 2 }, scores.reduce(0, +))
for (index, score) in scores.enumerated() where score > 25 {
    print(index, score)
}
