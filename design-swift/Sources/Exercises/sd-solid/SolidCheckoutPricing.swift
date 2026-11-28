// Kata: Open pricing rules (D04 · Open–closed: extending with protocols and enums)
import Foundation

public enum SolidCheckoutPricing {
    /// One line of the basket. Prices are whole pence, so no rounding creeps in.
    public struct LineItem: Sendable, Equatable {
        public let sku: String
        public let category: String
        public let unitPrice: Int
        public let quantity: Int

        public init(sku: String, category: String, unitPrice: Int, quantity: Int) {
            self.sku = sku
            self.category = category
            self.unitPrice = unitPrice
            self.quantity = quantity
        }

        public var total: Int { unitPrice * quantity }
    }

    public struct Cart: Sendable, Equatable {
        public var items: [LineItem]

        public init(_ items: [LineItem]) {
            self.items = items
        }

        public var subtotal: Int { items.reduce(0) { $0 + $1.total } }
    }

    /// Money taken off, with the label the receipt shows
    public struct Discount: Sendable, Equatable {
        public let label: String
        public let amount: Int

        public init(label: String, amount: Int) {
            self.label = label
            self.amount = amount
        }
    }

    /// One promotion. A new promotion is a new type that conforms; the engine never changes.
    public protocol DiscountRule: Sendable {
        /// The discount this rule gives `cart`, or nil when it doesn't apply. `earlier` holds the
        /// discounts already given by the rules before this one, in order.
        func discount(for cart: Cart, after earlier: [Discount]) -> Discount?
    }

    /// `percent`% off every item in `category`, rounded down to a whole penny
    public struct PercentOffCategory: DiscountRule {
        public let label: String
        public let category: String
        public let percent: Int

        public init(label: String, category: String, percent: Int) {
            self.label = label
            self.category = category
            self.percent = percent
        }

        public func discount(for cart: Cart, after earlier: [Discount]) -> Discount? {
            // Write your solution here, then run:
            // swift test --filter SolidCheckoutPricingTests
            return nil
        }
    }

    /// "3 for 2": for every `buy` units of `sku`, only `payFor` are charged
    public struct MultiBuy: DiscountRule {
        public let label: String
        public let sku: String
        public let buy: Int
        public let payFor: Int

        public init(label: String, sku: String, buy: Int, payFor: Int) {
            self.label = label
            self.sku = sku
            self.buy = buy
            self.payFor = payFor
        }

        public func discount(for cart: Cart, after earlier: [Discount]) -> Discount? {
            return nil
        }
    }

    /// `amount` off when the subtotal, less the discounts before this rule, is at least `minimum`
    public struct SpendThreshold: DiscountRule {
        public let label: String
        public let minimum: Int
        public let amount: Int

        public init(label: String, minimum: Int, amount: Int) {
            self.label = label
            self.minimum = minimum
            self.amount = amount
        }

        public func discount(for cart: Cart, after earlier: [Discount]) -> Discount? {
            return nil
        }
    }

    public struct Quote: Sendable, Equatable {
        public let subtotal: Int
        public let discounts: [Discount]
        public let total: Int

        public init(subtotal: Int, discounts: [Discount], total: Int) {
            self.subtotal = subtotal
            self.discounts = discounts
            self.total = total
        }
    }

    /// Applies its rules in order. It only knows `DiscountRule`, never a concrete promotion.
    public struct PricingEngine: Sendable {
        private let rules: [any DiscountRule]

        public init(rules: [any DiscountRule]) {
            self.rules = rules
        }

        /// The cart's subtotal, the discounts that applied (in rule order) and the total, never below 0
        public func quote(for cart: Cart) -> Quote {
            return Quote(subtotal: 0, discounts: [], total: 0)
        }
    }
}
