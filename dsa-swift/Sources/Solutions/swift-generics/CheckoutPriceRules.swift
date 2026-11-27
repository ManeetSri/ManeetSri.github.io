// Reference solution: Checkout price rules. Each rule type keeps the protocol's promise in its own way, and
// the two functions only ever use what the protocol guarantees. Applying k rules is O(k).

public enum CheckoutPriceRules {
    public protocol PriceRule {
        var label: String { get }
        func apply(to pennies: Int) -> Int
    }

    public struct PercentOff: PriceRule {
        public let percent: Int

        public init(percent: Int) {
            self.percent = percent
        }

        public var label: String {
            "\(percent)% off"
        }

        // Integer division rounds the discount down, so the customer never gets a fraction of a penny
        public func apply(to pennies: Int) -> Int {
            pennies - pennies * percent / 100
        }
    }

    public struct AmountOff: PriceRule {
        public let amount: Int

        public init(amount: Int) {
            self.amount = amount
        }

        public var label: String {
            "\(amount)p off"
        }

        public func apply(to pennies: Int) -> Int {
            max(0, pennies - amount)
        }
    }

    public struct PriceCap: PriceRule {
        public let cap: Int

        public init(cap: Int) {
            self.cap = cap
        }

        public var label: String {
            "at most \(cap)p"
        }

        public func apply(to pennies: Int) -> Int {
            min(pennies, cap)
        }
    }

    public static func finalPrice(of pennies: Int, applying rules: [any PriceRule]) -> Int {
        var price = pennies
        for rule in rules {
            price = rule.apply(to: price)
        }
        return price
    }

    // Strictly lower prices replace the best so far, so the earliest rule wins a tie
    public static func bestSingleRule(for pennies: Int, from rules: [any PriceRule]) -> String? {
        var best: (label: String, price: Int)?
        for rule in rules {
            let price = rule.apply(to: pennies)
            if best == nil || price < best!.price {
                best = (rule.label, price)
            }
        }
        return best?.label
    }
}
