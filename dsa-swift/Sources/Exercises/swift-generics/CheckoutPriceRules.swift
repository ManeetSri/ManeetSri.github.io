// Problem: Checkout price rules (M10 · Protocols and conformance)

public enum CheckoutPriceRules {
    /// A rule that changes a price, in pennies.
    public protocol PriceRule {
        /// A short description of the rule.
        var label: String { get }
        /// The price after this rule is applied to `pennies`.
        func apply(to pennies: Int) -> Int
    }

    // Write your solution here, then run:
    // swift test --filter CheckoutPriceRulesTests

    /// Takes `percent` percent off, rounding the discount down to a whole penny. Label: "10% off".
    public struct PercentOff: PriceRule {
        public let percent: Int

        public init(percent: Int) {
            self.percent = percent
        }

        public var label: String {
            return ""
        }

        public func apply(to pennies: Int) -> Int {
            return 0
        }
    }

    /// Takes `amount` pennies off, but never below zero. Label: "250p off".
    public struct AmountOff: PriceRule {
        public let amount: Int

        public init(amount: Int) {
            self.amount = amount
        }

        public var label: String {
            return ""
        }

        public func apply(to pennies: Int) -> Int {
            return 0
        }
    }

    /// Lowers any price above `cap` to `cap`. Label: "at most 500p".
    public struct PriceCap: PriceRule {
        public let cap: Int

        public init(cap: Int) {
            self.cap = cap
        }

        public var label: String {
            return ""
        }

        public func apply(to pennies: Int) -> Int {
            return 0
        }
    }

    /// The price after applying every rule in order, each to the result of the one before.
    public static func finalPrice(of pennies: Int, applying rules: [any PriceRule]) -> Int {
        return 0
    }

    /// The label of the rule that, used on its own, gives the lowest price for `pennies`.
    /// The earliest such rule on a tie, or nil if there are no rules.
    public static func bestSingleRule(for pennies: Int, from rules: [any PriceRule]) -> String? {
        return nil
    }
}
