// Reference solution: Containers with an item type. Each conforming type picks its Item through the types
// its methods use, and the generic functions name it as C.Item. add is O(1) for both shelves; the
// generic functions are O(n), using only count and item(at:).

public enum AssociatedItemContainers {
    public protocol Container {
        associatedtype Item
        mutating func add(_ item: Item)
        var count: Int { get }
        func item(at index: Int) -> Item?
    }

    public struct Shelf<Element>: Container {
        private var items: [Element] = []

        public init() {}

        public mutating func add(_ item: Element) {
            items.append(item)
        }

        public var count: Int {
            items.count
        }

        public func item(at index: Int) -> Element? {
            items.indices.contains(index) ? items[index] : nil
        }
    }

    public struct DistinctShelf<Element: Hashable>: Container {
        private var items: [Element] = []
        private var held: Set<Element> = []

        public init() {}

        // insert reports whether the item was new, so one lookup does both jobs
        public mutating func add(_ item: Element) {
            if held.insert(item).inserted {
                items.append(item)
            }
        }

        public var count: Int {
            items.count
        }

        public func item(at index: Int) -> Element? {
            items.indices.contains(index) ? items[index] : nil
        }
    }

    public static func items<C: Container>(of container: C) -> [C.Item] {
        var result: [C.Item] = []
        for index in 0..<container.count {
            if let item = container.item(at: index) {
                result.append(item)
            }
        }
        return result
    }

    public static func lastItem<C: Container>(of container: C) -> C.Item? {
        container.item(at: container.count - 1)
    }

    public static func occurrences<C: Container>(of target: C.Item, in container: C) -> Int
        where C.Item: Equatable {
        var found = 0
        for index in 0..<container.count where container.item(at: index) == target {
            found += 1
        }
        return found
    }

    public static func holdSameItems<C1: Container, C2: Container>(_ first: C1, _ second: C2) -> Bool
        where C1.Item == C2.Item, C1.Item: Equatable {
        guard first.count == second.count else {
            return false
        }
        for index in 0..<first.count where first.item(at: index) != second.item(at: index) {
            return false
        }
        return true
    }

    public static func addAll<C: Container>(_ items: [C.Item], to container: inout C) {
        for item in items {
            container.add(item)
        }
    }
}
