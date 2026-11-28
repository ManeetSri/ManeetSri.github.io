// Reference solution: Open pricing rules. The engine only knows the DiscountRule protocol, so a new
// promotion is a new type and the engine, already shipped and tested, never changes. Each rule sees the
// discounts given before it, which is what makes the order of rules meaningful.
import Foundation

public enum SolidCheckoutPricing {
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

    public struct Discount: Sendable, Equatable {
        public let label: String
        public let amount: Int

        public init(label: String, amount: Int) {
            self.label = label
            self.amount = amount
        }
    }

    public protocol DiscountRule: Sendable {
        func discount(for cart: Cart, after earlier: [Discount]) -> Discount?
    }

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
            let base = cart.items.filter { $0.category == category }.reduce(0) { $0 + $1.total }
            let amount = base * percent / 100
            return amount > 0 ? Discount(label: label, amount: amount) : nil
        }
    }

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
            guard let item = cart.items.first(where: { $0.sku == sku }) else { return nil }
            let free = (item.quantity / buy) * (buy - payFor)
            let amount = free * item.unitPrice
            return amount > 0 ? Discount(label: label, amount: amount) : nil
        }
    }

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
            let running = cart.subtotal - earlier.reduce(0) { $0 + $1.amount }
            return running >= minimum ? Discount(label: label, amount: amount) : nil
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

    public struct PricingEngine: Sendable {
        private let rules: [any DiscountRule]

        public init(rules: [any DiscountRule]) {
            self.rules = rules
        }

        public func quote(for cart: Cart) -> Quote {
            var discounts: [Discount] = []
            for rule in rules {
                if let discount = rule.discount(for: cart, after: discounts), discount.amount > 0 {
                    discounts.append(discount)
                }
            }
            let taken = discounts.reduce(0) { $0 + $1.amount }
            return Quote(subtotal: cart.subtotal, discounts: discounts, total: max(0, cart.subtotal - taken))
        }
    }
}
