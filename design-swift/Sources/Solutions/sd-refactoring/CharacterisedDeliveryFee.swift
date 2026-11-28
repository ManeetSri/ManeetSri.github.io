// Reference solution: Delivery fee. The legacy branches become named steps, applied in the order the
// old code applied them: the zone's price, then the member discount, the promo code and bulky handling.
// The quirks the characterisation tests pinned are kept on purpose and given names, so that changing one
// becomes a visible product decision rather than an accident of the refactor.
import Foundation

public enum CharacterisedDeliveryFee {
    public enum Speed: Sendable {
        case standard
        case express
    }

    public struct Order: Sendable, Equatable {
        public var subtotal: Int
        public var items: Int
        public var weight: Int
        public var country: String
        public var speed: Speed
        public var member: Bool
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

    /// Unchanged: the tests still compare against it. Once the new version has shipped and the
    /// golden master has stayed green for a release, it can be deleted along with that test.
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

    /// Standard delivery in GB is free strictly above £50: an order of exactly £50.00 still pays.
    private static let freeStandardAbove = 5000
    private static let memberExpressDiscount = 250
    private static let bulkyAbove = 10
    private static let bulkyHandling = 100

    /// Where a parcel goes, and what getting it there costs. Codes match exactly, as they always
    /// have: "gb" isn't GB.
    private enum Zone {
        case domestic
        case europe

        init?(country: String) {
            switch country {
            case "GB": self = .domestic
            case "IE", "FR", "DE": self = .europe
            default: return nil
            }
        }

        func price(for order: Order) -> Int {
            switch self {
            case .domestic:
                if order.speed == .standard && order.subtotal > freeStandardAbove { return 0 }
                let standard = 399 + weightSteps(order.weight) * 100
                return order.speed == .express ? standard + 500 : standard
            case .europe:
                let standard = 999 + weightSteps(order.weight) * 250
                return order.speed == .express ? standard * 2 : standard
            }
        }
    }

    /// Steps of 500 g over 2 kg, counted the legacy way: 2,001–2,499 g is one step, but exactly
    /// 2,500 g is already two.
    private static func weightSteps(_ weight: Int) -> Int {
        weight > 2000 ? (weight - 2000) / 500 + 1 : 0
    }

    public static func fee(for order: Order) -> Int? {
        guard let zone = Zone(country: order.country) else { return nil }
        var fee = zone.price(for: order)
        if order.member {
            // The legacy floor at zero can't trigger at today's prices; max(0, …) keeps it honest.
            fee = order.speed == .express ? max(0, fee - memberExpressDiscount) : 0
        }
        if order.promo == "FREESHIP" && zone == .domestic && order.speed == .standard {
            fee = 0
        }
        if order.items > bulkyAbove && fee > 0 {
            fee += bulkyHandling
        }
        return fee
    }
}
