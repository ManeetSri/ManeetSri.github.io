// Kata: Delivery fee, refactored behind characterisation tests (D15 · Refactoring safely)
import Foundation

public enum CharacterisedDeliveryFee {
    /// How fast the parcel travels
    public enum Speed: Sendable {
        case standard
        case express
    }

    /// Everything the fee depends on, gathered into one parameter object
    public struct Order: Sendable, Equatable {
        /// The basket's value, in pence
        public var subtotal: Int
        /// How many items are in the parcel
        public var items: Int
        /// The parcel's weight, in grams
        public var weight: Int
        /// The ISO country code of the delivery address, such as "GB"
        public var country: String
        public var speed: Speed
        /// Whether the customer pays for membership
        public var member: Bool
        /// The promo code typed at checkout, if any
        public var promo: String?

        public init(subtotal: Int, items: Int = 1, weight: Int = 0, country: String = "GB", speed: Speed = .standard, member: Bool = false, promo: String? = nil) {
            self.subtotal = subtotal
            self.items = items
            self.weight = weight
            self.country = country
            self.speed = speed
            self.member = member
            self.promo = promo
        }
    }

    /// The checkout's original fee calculation: pence, or -1 where the shop doesn't deliver. It's the
    /// oracle the characterisation tests compare your version against, so leave it exactly as it is.
    public static func legacyFee(subtotal: Int, items: Int, weight: Int, country: String, express: Bool, member: Bool, promo: String?) -> Int {
        var fee = 0
        if country == "GB" {
            if subtotal > 5000 && !express {
                fee = 0
            } else {
                fee = 399
                if weight > 2000 {
                    fee = fee + ((weight - 2000) / 500 + 1) * 100
                }
                if express {
                    fee = fee + 500
                }
            }
        } else if country == "IE" || country == "FR" || country == "DE" {
            fee = 999
            if weight > 2000 {
                fee = fee + ((weight - 2000) / 500 + 1) * 250
            }
            if express {
                fee = fee * 2
            }
        } else {
            return -1
        }
        if member {
            if express {
                fee = fee - 250
                if fee < 0 {
                    fee = 0
                }
            } else {
                fee = 0
            }
        }
        if promo == "FREESHIP" && country == "GB" && !express {
            fee = 0
        }
        if items > 10 && fee > 0 {
            fee = fee + 100
        }
        return fee
    }

    /// The same fee as `legacyFee` for every order, from code you'd be happy to change, or nil where
    /// the shop doesn't deliver.
    public static func fee(for order: Order) -> Int? {
        // Write your solution here, then run:
        // swift test --filter CharacterisedDeliveryFeeTests
        return nil
    }
}
