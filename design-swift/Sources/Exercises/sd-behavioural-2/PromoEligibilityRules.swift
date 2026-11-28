// Kata: Promo eligibility rules (D13 · Specification: composable business rules)
import Foundation

public enum PromoEligibilityRules {
    public enum Tier: Int, Comparable, Sendable {
        case standard, silver, gold

        public static func < (lhs: Tier, rhs: Tier) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    /// What the rules look at
    public struct Basket: Equatable, Sendable {
        public var subtotalPence: Int
        public var categories: Set<String>
        public var tier: Tier
        public var previousOrders: Int

        public init(subtotalPence: Int, categories: Set<String> = [], tier: Tier = .standard, previousOrders: Int = 0) {
            self.subtotalPence = subtotalPence
            self.categories = categories
            self.tier = tier
            self.previousOrders = previousOrders
        }
    }

    /// A promotion's rule, as a tree: four kinds of leaf, combined with all, any and not
    public indirect enum Rule: Equatable, Sendable {
        /// The subtotal is at least this many pence
        case minimumSubtotal(pence: Int)
        /// The basket has an item in this category
        case containsCategory(String)
        /// The customer's tier is this one or higher
        case tierAtLeast(Tier)
        /// The customer has never ordered before
        case firstOrder
        /// Every rule holds (an empty list always holds)
        case all([Rule])
        /// At least one rule holds (an empty list never holds)
        case any([Rule])
        /// The rule doesn't hold
        case not(Rule)

        /// Whether `basket` qualifies
        public func isSatisfied(by basket: Basket) -> Bool {
            // Write your solution here, then run:
            // swift test --filter PromoEligibilityRulesTests
            return false
        }

        /// The rules that explain why `basket` doesn't qualify: empty when it does. A failing leaf or `not`
        /// reports itself; a failing `all` or `any` reports what its failing children report, in order;
        /// a failing `any` with no children reports itself.
        public func unmet(by basket: Basket) -> [Rule] {
            return []
        }
    }
}
