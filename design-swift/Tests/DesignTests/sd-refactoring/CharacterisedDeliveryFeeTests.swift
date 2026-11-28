import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CharacterisedDeliveryFeeTests {
    typealias Fee = CharacterisedDeliveryFee

    private func fee(_ subtotal: Int = 1000, items: Int = 1, weight: Int = 0, country: String = "GB", speed: Fee.Speed = .standard, member: Bool = false, promo: String? = nil) -> Int? {
        Fee.fee(for: Fee.Order(subtotal: subtotal, items: items, weight: weight, country: country, speed: speed, member: member, promo: promo))
    }

    /// Every combination of values on either side of each threshold the legacy code tests
    private static let orders: [Fee.Order] = {
        var orders: [Fee.Order] = []
        for subtotal in [0, 4999, 5000, 5001, 12000] {
            for items in [1, 10, 11] {
                for weight in [0, 2000, 2001, 2499, 2500, 2501, 4100] {
                    for country in ["GB", "IE", "FR", "DE", "US", "gb"] {
                        for speed in [Fee.Speed.standard, .express] {
                            for member in [false, true] {
                                for promo in [nil, "FREESHIP", "freeship"] as [String?] {
                                    orders.append(Fee.Order(subtotal: subtotal, items: items, weight: weight, country: country, speed: speed, member: member, promo: promo))
                                }
                            }
                        }
                    }
                }
            }
        }
        return orders
    }()

    @Test("Matches the legacy fee for every combination of inputs: the golden master")
    func goldenMaster() {
        let differences = Self.orders.compactMap { order -> String? in
            let expected = Fee.legacyFee(subtotal: order.subtotal, items: order.items, weight: order.weight, country: order.country, express: order.speed == .express, member: order.member, promo: order.promo)
            let actual = Fee.fee(for: order) ?? -1
            return actual == expected ? nil : "\(order): legacy \(expected), yours \(actual)"
        }
        #expect(Self.orders.count == 7560)
        #expect(differences.isEmpty, "\(differences.count) of \(Self.orders.count) orders differ. First: \(differences.first ?? "")")
    }

    @Test("Standard delivery in GB is free only above £50, never for express")
    func freeAboveFifty() {
        #expect(fee(5001) == 0)
        #expect(fee(5000) == 399)
        #expect(fee(5001, speed: .express) == 899)
    }

    @Test("Weight is charged per started 500 g over 2 kg, and exactly 2,500 g counts as two steps")
    func weightSteps() {
        #expect(fee(weight: 2000) == 399)
        #expect(fee(weight: 2001) == 499)
        #expect(fee(weight: 2499) == 499)
        #expect(fee(weight: 2500) == 599)
        #expect(fee(weight: 4100) == 899)
    }

    @Test("Europe has its own prices, no free threshold, and express doubles the whole fee")
    func europe() {
        #expect(fee(country: "IE") == 999)
        #expect(fee(12000, country: "IE") == 999)
        #expect(fee(weight: 3000, country: "FR") == 1749)
        #expect(fee(weight: 3000, country: "DE", speed: .express) == 3498)
    }

    @Test("Members get standard delivery free everywhere, and £2.50 off express")
    func members() {
        #expect(fee(member: true) == 0)
        #expect(fee(country: "IE", member: true) == 0)
        #expect(fee(speed: .express, member: true) == 649)
        #expect(fee(country: "FR", speed: .express, member: true) == 1748)
    }

    @Test("FREESHIP covers standard delivery in GB only, and is case-sensitive")
    func promo() {
        #expect(fee(promo: "FREESHIP") == 0)
        #expect(fee(speed: .express, promo: "FREESHIP") == 899)
        #expect(fee(country: "IE", promo: "FREESHIP") == 999)
        #expect(fee(promo: "freeship") == 399)
    }

    @Test("Bulky handling is added only for more than 10 items, and only when delivery isn't free")
    func bulkyHandling() {
        #expect(fee(items: 11) == 499)
        #expect(fee(items: 10) == 399)
        #expect(fee(items: 11, speed: .express) == 999)
        #expect(fee(6000, items: 11) == 0)
        #expect(fee(items: 11, member: true) == 0)
    }

    @Test("Country codes match exactly, and other countries aren't delivered to")
    func countries() {
        #expect(fee(country: "GB") == 399)
        #expect(fee(country: "US") == nil)
        #expect(fee(country: "gb") == nil)
    }
}
