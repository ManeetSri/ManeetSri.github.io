// Kata: Erased search filters (D06 · some vs any, existential cost and type erasure)
public enum SearchFilterErasure {
    /// A filter chip on a search screen. Filters are Hashable, so the screen can keep the active ones in a Set.
    public protocol SearchFilter<Item>: Hashable, Sendable {
        associatedtype Item
        /// The text on the chip, such as "Under £20"
        var label: String { get }
        /// Whether an item passes this filter
        func matches(_ item: Item) -> Bool
    }

    /// Any filter over `Item`, whatever its concrete type, as one Hashable type. Two erased filters are equal
    /// only when they wrap the same concrete type and those values are equal.
    public struct AnySearchFilter<Item>: SearchFilter {
        public init<Filter: SearchFilter>(_ filter: Filter) where Filter.Item == Item {
            // Write your solution here, then run:
            // swift test --filter SearchFilterErasureTests
        }

        public var label: String { "" }

        public func matches(_ item: Item) -> Bool {
            false
        }

        public static func == (lhs: AnySearchFilter, rhs: AnySearchFilter) -> Bool {
            false
        }

        public func hash(into hasher: inout Hasher) {}

        /// The wrapped filter, if it's a `Filter`
        public func base<Filter: SearchFilter>(as type: Filter.Type) -> Filter? {
            nil
        }
    }

    /// The items that pass every filter, in their original order
    public static func apply<Item>(_ filters: Set<AnySearchFilter<Item>>, to items: [Item]) -> [Item] {
        []
    }
}
