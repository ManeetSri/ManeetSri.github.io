// Reference solution: Erased search filters. The eraser stores the filter as an existential and adds
// the conformance an existential can't have: Hashable. Equality opens the left filter's concrete type
// and casts the right one to it, so two filters are equal only when they're the same type and equal.
public enum SearchFilterErasure {
    public protocol SearchFilter<Item>: Hashable, Sendable {
        associatedtype Item
        var label: String { get }
        func matches(_ item: Item) -> Bool
    }

    public struct AnySearchFilter<Item>: SearchFilter {
        private let wrapped: any SearchFilter<Item>

        public init<Filter: SearchFilter>(_ filter: Filter) where Filter.Item == Item {
            // An already erased filter is unwrapped, so erasing twice gives the same value as erasing once
            if let erased = filter as? AnySearchFilter<Item> {
                self = erased
            } else {
                wrapped = filter
            }
        }

        public var label: String { wrapped.label }

        public func matches(_ item: Item) -> Bool {
            wrapped.matches(item)
        }

        public static func == (lhs: AnySearchFilter, rhs: AnySearchFilter) -> Bool {
            // Passing `any SearchFilter<Item>` to a generic parameter opens it: inside, F is the concrete type
            func isEqual<F: SearchFilter>(_ left: F, to right: any SearchFilter<Item>) -> Bool {
                guard let right = right as? F else { return false }
                return left == right
            }
            return isEqual(lhs.wrapped, to: rhs.wrapped)
        }

        public func hash(into hasher: inout Hasher) {
            // Mixing in the type keeps equal-looking filters of different types apart
            hasher.combine(ObjectIdentifier(type(of: wrapped)))
            wrapped.hash(into: &hasher)
        }

        public func base<Filter: SearchFilter>(as type: Filter.Type) -> Filter? {
            wrapped as? Filter
        }
    }

    public static func apply<Item>(_ filters: Set<AnySearchFilter<Item>>, to items: [Item]) -> [Item] {
        items.filter { item in filters.allSatisfy { $0.matches(item) } }
    }
}
