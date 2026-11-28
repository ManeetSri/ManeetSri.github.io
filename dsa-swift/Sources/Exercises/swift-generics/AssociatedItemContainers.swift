// Problem: Containers with an item type (M10 · Associated types)

public enum AssociatedItemContainers {
    public protocol Container {
        associatedtype Item
        /// Offers `item` to the container, which decides whether to keep it.
        mutating func add(_ item: Item)
        /// How many items the container holds.
        var count: Int { get }
        /// The item at `index` (0 is the first one added), or nil if there's no such index.
        func item(at index: Int) -> Item?
    }

    // Write your solution here, then run:
    // swift test --filter AssociatedItemContainersTests
    // Add whatever private storage the two shelves need.

    /// Keeps every item, in the order added.
    public struct Shelf<Element>: Container {
        public init() {}

        public mutating func add(_ item: Element) {
        }

        public var count: Int {
            return 0
        }

        public func item(at index: Int) -> Element? {
            return nil
        }
    }

    /// Keeps each distinct item once, in the order first added. Adding an item it already holds does nothing.
    public struct DistinctShelf<Element: Hashable>: Container {
        public init() {}

        public mutating func add(_ item: Element) {
        }

        public var count: Int {
            return 0
        }

        public func item(at index: Int) -> Element? {
            return nil
        }
    }

    /// Every item in `container`, in order.
    public static func items<C: Container>(of container: C) -> [C.Item] {
        return []
    }

    /// The last item in `container`, or nil if it's empty.
    public static func lastItem<C: Container>(of container: C) -> C.Item? {
        return nil
    }

    /// How many items in `container` are equal to `target`.
    public static func occurrences<C: Container>(of target: C.Item, in container: C) -> Int
        where C.Item: Equatable {
        return 0
    }

    /// True when both containers hold equal items in the same order, even if they're different types.
    public static func holdSameItems<C1: Container, C2: Container>(_ first: C1, _ second: C2) -> Bool
        where C1.Item == C2.Item, C1.Item: Equatable {
        return false
    }

    /// Offers every item in `items` to `container`, in order.
    public static func addAll<C: Container>(_ items: [C.Item], to container: inout C) {
    }
}
