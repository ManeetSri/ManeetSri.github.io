import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias SearchFilter = SearchFilterErasure.SearchFilter
private typealias AnyFilter = SearchFilterErasure.AnySearchFilter<FilterProduct>

private struct FilterProduct: Equatable, Sendable {
    let name: String
    let pence: Int
    let brand: String
    let inStock: Bool
}

private struct PriceAtMost: SearchFilter {
    let pence: Int
    var label: String { "Under £\(pence / 100)" }
    func matches(_ item: FilterProduct) -> Bool { item.pence <= pence }
}

private struct BrandIs: SearchFilter {
    let name: String
    var label: String { name }
    func matches(_ item: FilterProduct) -> Bool { item.brand == name }
}

/// The same stored property as BrandIs, but a different filter: it must never equal a BrandIs
private struct BrandStartsWith: SearchFilter {
    let name: String
    var label: String { "\(name)…" }
    func matches(_ item: FilterProduct) -> Bool { item.brand.hasPrefix(name) }
}

private struct InStockOnly: SearchFilter {
    var label: String { "In stock" }
    func matches(_ item: FilterProduct) -> Bool { item.inStock }
}

private let products = [
    FilterProduct(name: "Kettle", pence: 2_499, brand: "Acme", inStock: true),
    FilterProduct(name: "Toaster", pence: 1_850, brand: "Acme", inStock: false),
    FilterProduct(name: "Lamp", pence: 1_200, brand: "Lumen", inStock: true),
    FilterProduct(name: "Fan", pence: 3_900, brand: "Acme Pro", inStock: true),
]

@Suite struct SearchFilterErasureTests {
    @Test("Forwards the label and the matching to the wrapped filter")
    func forwards() {
        let filter = AnyFilter(PriceAtMost(pence: 2_000))
        #expect(filter.label == "Under £20")
        #expect(filter.matches(products[1]))
        #expect(!filter.matches(products[0]))
    }

    @Test("Equal when the wrapped filters are the same type with equal values")
    func sameTypeEquality() {
        #expect(AnyFilter(BrandIs(name: "Acme")) == AnyFilter(BrandIs(name: "Acme")))
        #expect(AnyFilter(BrandIs(name: "Acme")) != AnyFilter(BrandIs(name: "Lumen")))
        #expect(AnyFilter(InStockOnly()) == AnyFilter(InStockOnly()))
    }

    @Test("Filters of different types are never equal, even with the same fields")
    func differentTypes() {
        #expect(AnyFilter(BrandIs(name: "Acme")) != AnyFilter(BrandStartsWith(name: "Acme")))
        #expect(AnyFilter(InStockOnly()) != AnyFilter(PriceAtMost(pence: 0)))
        let chips = [AnyFilter(BrandIs(name: "Acme")), AnyFilter(BrandStartsWith(name: "Acme")), AnyFilter(BrandIs(name: "Acme"))]
        #expect(Set(chips).count == 2)
    }

    @Test("A Set of active filters keeps one of each, and toggling one off removes it")
    func setOfFilters() {
        var active: Set<AnyFilter> = []
        active.insert(AnyFilter(BrandIs(name: "Acme")))
        active.insert(AnyFilter(BrandIs(name: "Acme")))
        active.insert(AnyFilter(BrandStartsWith(name: "Acme")))
        active.insert(AnyFilter(InStockOnly()))
        #expect(active.count == 3)
        #expect(active.contains(AnyFilter(InStockOnly())))

        active.remove(AnyFilter(BrandIs(name: "Acme")))
        #expect(active.count == 2)
        #expect(!active.contains(AnyFilter(BrandIs(name: "Acme"))))
        #expect(active.contains(AnyFilter(BrandStartsWith(name: "Acme"))))
    }

    @Test("Recovers the concrete filter, or nil when it's another type")
    func base() {
        let filter = AnyFilter(PriceAtMost(pence: 1_500))
        #expect(filter.base(as: PriceAtMost.self) == PriceAtMost(pence: 1_500))
        #expect(filter.base(as: BrandIs.self) == nil)
    }

    @Test("Erasing an erased filter again doesn't nest it")
    func noDoubleWrapping() {
        let once = AnyFilter(BrandIs(name: "Lumen"))
        let twice = AnyFilter(once)
        #expect(twice == once)
        #expect(twice.base(as: BrandIs.self) == BrandIs(name: "Lumen"))
        #expect(Set([once, twice]).count == 1)
    }

    @Test("apply keeps the items that pass every filter, in their original order")
    func applyFilters() {
        let active: Set<AnyFilter> = [AnyFilter(BrandStartsWith(name: "Acme")), AnyFilter(InStockOnly())]
        #expect(SearchFilterErasure.apply(active, to: products).map(\.name) == ["Kettle", "Fan"])
        #expect(SearchFilterErasure.apply([], to: products) == products)
    }
}
