// Reference solution: A copy-on-write stack. Every mutating method calls makeUnique() first, which copies
// the storage only if another stack shares it. Push and pop are O(1) (amortised for push) when the storage
// is unique; the first change after sharing copies it in O(n).

public enum CopyOnWriteStack {
    final class Storage {
        var items: [Int]

        init(items: [Int]) {
            self.items = items
        }
    }

    public struct Stack {
        private var storage: Storage

        public init() {
            storage = Storage(items: [])
        }

        public init(_ elements: [Int]) {
            storage = Storage(items: elements)
        }

        public var storageID: ObjectIdentifier {
            ObjectIdentifier(storage)
        }

        public var count: Int { storage.items.count }

        public var isEmpty: Bool { storage.items.isEmpty }

        public var top: Int? { storage.items.last }

        public var elements: [Int] { storage.items }

        /// Gives this stack its own storage if another stack shares it.
        private mutating func makeUnique() {
            if !isKnownUniquelyReferenced(&storage) {
                storage = Storage(items: storage.items)
            }
        }

        public mutating func push(_ value: Int) {
            makeUnique()
            storage.items.append(value)
        }

        public mutating func pop() -> Int? {
            makeUnique()
            return storage.items.popLast()
        }

        public mutating func removeAll() {
            makeUnique()
            storage.items.removeAll()
        }

        public func isSharingStorage(with other: Stack) -> Bool {
            storageID == other.storageID
        }
    }
}
