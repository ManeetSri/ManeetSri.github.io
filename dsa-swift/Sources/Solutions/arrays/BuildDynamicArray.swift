// Reference solution: Build a dynamic array. Slots 0..<count of a buffer of optionals hold the
// elements; the buffer's size is the capacity. A full buffer is replaced by one twice the size, so
// append is amortised O(1). insert and remove shift the later elements: O(n). Subscripts are O(1).

public enum BuildDynamicArray {
    public struct DynamicArray<Element> {
        private var buffer: [Element?] = []
        private var storedCount = 0

        public init() {}

        public var count: Int {
            storedCount
        }

        public var capacity: Int {
            buffer.count
        }

        public var isEmpty: Bool {
            storedCount == 0
        }

        public mutating func append(_ element: Element) {
            growIfFull()
            buffer[storedCount] = element
            storedCount += 1
        }

        public mutating func insert(_ element: Element, at index: Int) {
            precondition(index >= 0 && index <= storedCount, "Index out of range")
            growIfFull()
            // Shift from the back, so nothing is overwritten before it has moved
            var position = storedCount
            while position > index {
                buffer[position] = buffer[position - 1]
                position -= 1
            }
            buffer[index] = element
            storedCount += 1
        }

        public mutating func remove(at index: Int) -> Element {
            precondition(index >= 0 && index < storedCount, "Index out of range")
            let removed = buffer[index]!
            for position in index..<(storedCount - 1) {
                buffer[position] = buffer[position + 1]
            }
            buffer[storedCount - 1] = nil     // let go of the old last element
            storedCount -= 1
            return removed
        }

        public mutating func popLast() -> Element? {
            guard storedCount > 0 else { return nil }
            storedCount -= 1
            let removed = buffer[storedCount]
            buffer[storedCount] = nil
            return removed
        }

        public subscript(index: Int) -> Element {
            get {
                precondition(index >= 0 && index < storedCount, "Index out of range")
                return buffer[index]!
            }
            set {
                precondition(index >= 0 && index < storedCount, "Index out of range")
                buffer[index] = newValue
            }
        }

        // Doubles the capacity (0 becomes 1) when every slot is in use, copying each element across
        private mutating func growIfFull() {
            guard storedCount == buffer.count else { return }
            var bigger = [Element?](repeating: nil, count: max(1, buffer.count * 2))
            for position in 0..<storedCount {
                bigger[position] = buffer[position]
            }
            buffer = bigger
        }
    }
}
