import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PromoEligibilityRulesTests {
    typealias Rule = PromoEligibilityRules.Rule
    typealias Basket = PromoEligibilityRules.Basket

    static let returningSilver = Basket(subtotalPence: 3000, categories: ["toys", "books"], tier: .silver, previousOrders: 4)
    static let newStandard = Basket(subtotalPence: 1200, categories: ["garden"], tier: .standard, previousOrders: 0)

    static let leaves: [(Rule, Basket, Bool)] = [
        (.minimumSubtotal(pence: 2500), returningSilver, true),
        (.minimumSubtotal(pence: 3000), returningSilver, true),
        (.minimumSubtotal(pence: 3001), returningSilver, false),
        (.containsCategory("toys"), returningSilver, true),
        (.containsCategory("toys"), newStandard, false),
        (.tierAtLeast(.silver), returningSilver, true),
        (.tierAtLeast(.gold), returningSilver, false),
        (.tierAtLeast(.standard), newStandard, true),
        (.firstOrder, newStandard, true),
        (.firstOrder, returningSilver, false),
    ]

    @Test("Each kind of leaf rule checks one thing about the basket", arguments: leaves)
    func leafRules(rule: Rule, basket: Basket, expected: Bool) {
        #expect(rule.isSatisfied(by: basket) == expected)
    }

    @Test("all, any and not combine rules")
    func combinators() {
        let basket = Self.returningSilver
        #expect(Rule.all([.minimumSubtotal(pence: 2000), .containsCategory("books")]).isSatisfied(by: basket))
        #expect(!Rule.all([.minimumSubtotal(pence: 2000), .containsCategory("garden")]).isSatisfied(by: basket))
        #expect(Rule.any([.containsCategory("garden"), .tierAtLeast(.silver)]).isSatisfied(by: basket))
        #expect(!Rule.any([.containsCategory("garden"), .firstOrder]).isSatisfied(by: basket))
        #expect(Rule.not(.firstOrder).isSatisfied(by: basket))
        #expect(!Rule.not(.containsCategory("toys")).isSatisfied(by: basket))
    }

    @Test("An empty all always holds, and an empty any never does")
    func emptyCombinators() {
        for basket in [Self.returningSilver, Self.newStandard] {
            #expect(Rule.all([]).isSatisfied(by: basket))
            #expect(!Rule.any([]).isSatisfied(by: basket))
        }
    }

    @Test("Rules nest to any depth")
    func nested() {
        // £25 or more, and either toys or gold tier, and not a first order
        let spring = Rule.all([
            .minimumSubtotal(pence: 2500),
            .any([.containsCategory("toys"), .tierAtLeast(.gold)]),
            .not(.firstOrder),
        ])
        #expect(spring.isSatisfied(by: Self.returningSilver))
        #expect(!spring.isSatisfied(by: Self.newStandard))

        var goldNoToys = Self.returningSilver
        goldNoToys.categories = ["books"]
        goldNoToys.tier = .gold
        #expect(spring.isSatisfied(by: goldNoToys))
        goldNoToys.tier = .silver
        #expect(!spring.isSatisfied(by: goldNoToys))
    }

    @Test("A basket that qualifies has nothing unmet")
    func nothingUnmet() {
        let qualifying: [(Rule, Basket)] = [
            (.minimumSubtotal(pence: 1000), Self.returningSilver),
            (.all([]), Self.newStandard),
            (.all([.firstOrder, .containsCategory("garden")]), Self.newStandard),
        ]
        for (rule, basket) in qualifying {
            #expect(rule.isSatisfied(by: basket))
            #expect(rule.unmet(by: basket) == [])
        }
    }

    @Test("A failing leaf or not reports itself")
    func failingLeaf() {
        #expect(Rule.minimumSubtotal(pence: 2500).unmet(by: Self.newStandard) == [.minimumSubtotal(pence: 2500)])
        #expect(Rule.not(.firstOrder).unmet(by: Self.newStandard) == [.not(.firstOrder)])
    }

    @Test("A failing all reports only its failing children, in order, through nested rules")
    func failingAll() {
        let rule = Rule.all([
            .minimumSubtotal(pence: 2500),
            .containsCategory("garden"),
            .all([.tierAtLeast(.gold), .firstOrder]),
        ])
        #expect(rule.unmet(by: Self.newStandard) == [.minimumSubtotal(pence: 2500), .tierAtLeast(.gold)])
    }

    @Test("A failing any reports every child's reasons, since all of them failed")
    func failingAny() {
        let rule = Rule.any([.containsCategory("toys"), .tierAtLeast(.silver)])
        #expect(rule.unmet(by: Self.newStandard) == [.containsCategory("toys"), .tierAtLeast(.silver)])
        #expect(Rule.any([]).unmet(by: Self.newStandard) == [.any([])])
    }

    @Test("A checkout can turn unmet rules into advice")
    func adviceFromUnmet() {
        let freeDelivery = Rule.all([.minimumSubtotal(pence: 2500), .not(.containsCategory("furniture"))])
        let shortfall = freeDelivery.unmet(by: Self.newStandard).compactMap { rule -> Int? in
            guard case .minimumSubtotal(let pence) = rule else { return nil }
            return pence - Self.newStandard.subtotalPence
        }
        #expect(shortfall == [1300])
    }

    static let combinations: [Rule] = [
        .all([]), .any([]), .firstOrder, .not(.firstOrder),
        .all([.minimumSubtotal(pence: 2000), .any([.containsCategory("garden"), .not(.tierAtLeast(.silver))])]),
        .any([.all([]), .firstOrder]),
        .not(.all([.containsCategory("toys"), .containsCategory("books")])),
        .any([.not(.any([])), .minimumSubtotal(pence: 99_999)]),
    ]

    @Test("unmet is empty exactly when the rule is satisfied", arguments: combinations)
    func unmetMatchesSatisfied(rule: Rule) {
        for basket in [Self.returningSilver, Self.newStandard] {
            #expect(rule.unmet(by: basket).isEmpty == rule.isSatisfied(by: basket))
        }
    }
}
