import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SolidCheckoutPricingTests {
    typealias Cart = SolidCheckoutPricing.Cart
    typealias Discount = SolidCheckoutPricing.Discount
    typealias LineItem = SolidCheckoutPricing.LineItem
    typealias Quote = SolidCheckoutPricing.Quote

    // Bakery 500 + 199, drinks 840, pantry 3,600: a subtotal of 5,139p
    private func basket(colas: Int = 7) -> Cart {
        Cart([
            LineItem(sku: "BREAD", category: "bakery", unitPrice: 250, quantity: 2),
            LineItem(sku: "CROISSANT", category: "bakery", unitPrice: 199, quantity: 1),
            LineItem(sku: "COLA", category: "drinks", unitPrice: 120, quantity: colas),
            LineItem(sku: "BEANS", category: "pantry", unitPrice: 3_600, quantity: 1),
        ])
    }

    private let bakery = SolidCheckoutPricing.PercentOffCategory(label: "10% off bakery", category: "bakery", percent: 10)
    private let colaDeal = SolidCheckoutPricing.MultiBuy(label: "Cola 3 for 2", sku: "COLA", buy: 3, payFor: 2)
    private let bigSpend = SolidCheckoutPricing.SpendThreshold(label: "£5 off £50", minimum: 5_000, amount: 500)

    // Rules the engine has never heard of: the open–closed principle in action
    private struct Welcome: SolidCheckoutPricing.DiscountRule {
        func discount(for cart: Cart, after earlier: [Discount]) -> Discount? {
            Discount(label: "Welcome: 20% off", amount: (cart.subtotal - earlier.reduce(0) { $0 + $1.amount }) / 5)
        }
    }

    private struct Fixed: SolidCheckoutPricing.DiscountRule {
        let amount: Int
        func discount(for cart: Cart, after earlier: [Discount]) -> Discount? {
            Discount(label: "Fixed \(amount)", amount: amount)
        }
    }

    @Test("With no rules, the total is the subtotal")
    func noRules() {
        let quote = SolidCheckoutPricing.PricingEngine(rules: []).quote(for: basket())
        #expect(quote == Quote(subtotal: 5_139, discounts: [], total: 5_139))
    }

    @Test("Percent off a category rounds down to a whole penny, and skips carts without that category")
    func percentOff() {
        #expect(bakery.discount(for: basket(), after: []) == Discount(label: "10% off bakery", amount: 69))
        let halfPantry = SolidCheckoutPricing.PercentOffCategory(label: "Half-price pantry", category: "pantry", percent: 50)
        #expect(halfPantry.discount(for: basket(), after: [])?.amount == 1_800)
        let toys = SolidCheckoutPricing.PercentOffCategory(label: "Toys", category: "toys", percent: 25)
        #expect(toys.discount(for: basket(), after: []) == nil)
    }

    @Test("Multi-buy gives the free units for every complete group")
    func multiBuy() {
        #expect(colaDeal.discount(for: basket(colas: 7), after: []) == Discount(label: "Cola 3 for 2", amount: 240))
        #expect(colaDeal.discount(for: basket(colas: 6), after: [])?.amount == 240)
        #expect(colaDeal.discount(for: basket(colas: 2), after: []) == nil)
        let fiveForThree = SolidCheckoutPricing.MultiBuy(label: "5 for 3", sku: "COLA", buy: 5, payFor: 3)
        #expect(fiveForThree.discount(for: basket(colas: 11), after: [])?.amount == 480)
        let missing = SolidCheckoutPricing.MultiBuy(label: "Tea", sku: "TEA", buy: 2, payFor: 1)
        #expect(missing.discount(for: basket(), after: []) == nil)
    }

    @Test("A spend threshold counts the discounts before it, and includes the boundary")
    func threshold() {
        #expect(bigSpend.discount(for: basket(), after: []) == Discount(label: "£5 off £50", amount: 500))
        #expect(bigSpend.discount(for: basket(), after: [Discount(label: "x", amount: 139)])?.amount == 500)
        #expect(bigSpend.discount(for: basket(), after: [Discount(label: "x", amount: 140)]) == nil)
    }

    @Test("The engine applies rules in order, so order changes the price")
    func orderMatters() {
        let thresholdLast = SolidCheckoutPricing.PricingEngine(rules: [bakery, colaDeal, bigSpend]).quote(for: basket())
        #expect(thresholdLast == Quote(subtotal: 5_139, discounts: [
            Discount(label: "10% off bakery", amount: 69),
            Discount(label: "Cola 3 for 2", amount: 240),
        ], total: 4_830))

        let thresholdFirst = SolidCheckoutPricing.PricingEngine(rules: [bigSpend, bakery, colaDeal]).quote(for: basket())
        #expect(thresholdFirst.discounts.map(\.amount) == [500, 69, 240])
        #expect(thresholdFirst.total == 4_330)
    }

    @Test("A rule written after the engine works without changing it")
    func openForExtension() {
        let quote = SolidCheckoutPricing.PricingEngine(rules: [colaDeal, Welcome()]).quote(for: basket())
        #expect(quote.discounts == [Discount(label: "Cola 3 for 2", amount: 240), Discount(label: "Welcome: 20% off", amount: 979)])
        #expect(quote.total == 3_920)
    }

    @Test("Discounts of nothing are dropped, and the total never goes below zero")
    func limits() {
        let quote = SolidCheckoutPricing.PricingEngine(rules: [Fixed(amount: 0), Fixed(amount: -50), bakery, Fixed(amount: 10_000)]).quote(for: basket())
        #expect(quote.discounts.map(\.amount) == [69, 10_000])
        #expect(quote.total == 0)
        #expect(quote.subtotal == 5_139)
    }
}
