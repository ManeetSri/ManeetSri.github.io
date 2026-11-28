import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CheckoutPriceRulesTests {
    typealias PriceRule = CheckoutPriceRules.PriceRule
    typealias PercentOff = CheckoutPriceRules.PercentOff
    typealias AmountOff = CheckoutPriceRules.AmountOff
    typealias PriceCap = CheckoutPriceRules.PriceCap

    /// A rule written outside the module: any type can conform to the protocol.
    private struct HalfPrice: PriceRule {
        var label: String { "half price" }
        func apply(to pennies: Int) -> Int { pennies / 2 }
    }

    @Test("Percentage discounts round the discount down", arguments: [
        (10, 1_000, 900),
        (10, 999, 900),
        (25, 199, 150),
        (100, 500, 0),
        (0, 500, 500),
        (50, 0, 0),
    ])
    func percentOff(percent: Int, pennies: Int, expected: Int) {
        let rule = PercentOff(percent: percent)
        #expect(rule.apply(to: pennies) == expected)
        #expect(rule.label == "\(percent)% off")
    }

    @Test("Amount discounts never go below zero", arguments: [(250, 1_000, 750), (250, 250, 0), (250, 100, 0), (0, 80, 80)])
    func amountOff(amount: Int, pennies: Int, expected: Int) {
        let rule = AmountOff(amount: amount)
        #expect(rule.apply(to: pennies) == expected)
        #expect(rule.label == "\(amount)p off")
    }

    @Test("A cap only lowers prices above it", arguments: [(500, 800, 500), (500, 300, 300), (500, 500, 500)])
    func priceCap(cap: Int, pennies: Int, expected: Int) {
        let rule = PriceCap(cap: cap)
        #expect(rule.apply(to: pennies) == expected)
        #expect(rule.label == "at most \(cap)p")
    }

    @Test("Rules apply in order, and order matters")
    func order() {
        #expect(CheckoutPriceRules.finalPrice(of: 1_000, applying: [PercentOff(percent: 10), AmountOff(amount: 250)]) == 650)
        #expect(CheckoutPriceRules.finalPrice(of: 1_000, applying: [AmountOff(amount: 250), PercentOff(percent: 10)]) == 675)
        #expect(CheckoutPriceRules.finalPrice(of: 2_000, applying: [PriceCap(cap: 1_500), PercentOff(percent: 50)]) == 750)
        #expect(CheckoutPriceRules.finalPrice(of: 2_000, applying: [PercentOff(percent: 50), PriceCap(cap: 1_500)]) == 1_000)
    }

    @Test("No rules leave the price alone")
    func noRules() {
        #expect(CheckoutPriceRules.finalPrice(of: 1_234, applying: []) == 1_234)
        #expect(CheckoutPriceRules.bestSingleRule(for: 1_234, from: []) == nil)
    }

    @Test("A long list of rules")
    func manyRules() {
        let rules: [any PriceRule] = Array(repeating: AmountOff(amount: 1), count: 10_000)
        #expect(CheckoutPriceRules.finalPrice(of: 25_000, applying: rules) == 15_000)
        #expect(CheckoutPriceRules.finalPrice(of: 5_000, applying: rules) == 0)
    }

    @Test("The best single rule gives the lowest price on its own")
    func bestSingleRule() {
        let rules: [any PriceRule] = [PercentOff(percent: 10), AmountOff(amount: 250), PriceCap(cap: 800)]
        #expect(CheckoutPriceRules.bestSingleRule(for: 1_000, from: rules) == "250p off")
        #expect(CheckoutPriceRules.bestSingleRule(for: 5_000, from: rules) == "at most 800p")
        #expect(CheckoutPriceRules.bestSingleRule(for: 2_000, from: rules) == "at most 800p")
    }

    @Test("Ties go to the earliest rule")
    func ties() {
        let rules: [any PriceRule] = [AmountOff(amount: 100), PercentOff(percent: 10)]
        #expect(CheckoutPriceRules.bestSingleRule(for: 1_000, from: rules) == "100p off")
        #expect(CheckoutPriceRules.bestSingleRule(for: 300, from: [PriceCap(cap: 500), AmountOff(amount: 0)]) == "at most 500p")
    }

    @Test("Rules from outside the module work too")
    func customRule() {
        let rules: [any PriceRule] = [AmountOff(amount: 100), HalfPrice()]
        #expect(CheckoutPriceRules.finalPrice(of: 1_000, applying: rules) == 450)
        #expect(CheckoutPriceRules.bestSingleRule(for: 1_000, from: rules) == "half price")
    }
}
