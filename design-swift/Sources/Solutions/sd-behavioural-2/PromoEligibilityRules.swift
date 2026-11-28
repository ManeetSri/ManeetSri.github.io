// Reference solution: Promo eligibility rules. The rule is a tree, so it can be interpreted more than
// one way: `isSatisfied` evaluates it, and `unmet` walks it again to explain a failure. Each operation
// is one recursive switch, the enum form of a visitor. O(n) in the number of rules for both.
import Foundation

public enum PromoEligibilityRules {
    public enum Tier: Int, Comparable, Sendable {
        case standard, silver, gold

        public static func < (lhs: Tier, rhs: Tier) -> Bool { lhs.rawValue < rhs.rawValue }
    }

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

    public indirect enum Rule: Equatable, Sendable {
        case minimumSubtotal(pence: Int)
        case containsCategory(String)
        case tierAtLeast(Tier)
        case firstOrder
        case all([Rule])
        case any([Rule])
        case not(Rule)

        public func isSatisfied(by basket: Basket) -> Bool {
            switch self {
            case .minimumSubtotal(let pence): basket.subtotalPence >= pence
            case .containsCategory(let category): basket.categories.contains(category)
            case .tierAtLeast(let tier): basket.tier >= tier
            case .firstOrder: basket.previousOrders == 0
            case .all(let rules): rules.allSatisfy { $0.isSatisfied(by: basket) }
            case .any(let rules): rules.contains { $0.isSatisfied(by: basket) }
            case .not(let rule): !rule.isSatisfied(by: basket)
            }
        }

        public func unmet(by basket: Basket) -> [Rule] {
            guard !isSatisfied(by: basket) else { return [] }
            switch self {
            case .minimumSubtotal, .containsCategory, .tierAtLeast, .firstOrder, .not:
                return [self]
            case .any(let rules) where rules.isEmpty:
                return [self]
            case .all(let rules), .any(let rules):
                // Satisfied children report nothing, so only the failures remain
                return rules.flatMap { $0.unmet(by: basket) }
            }
        }
    }
}
