// Reference solution: Ride types. Each leg of the old switches moved into the type it described.
// Standard, XL and Lux share a Tariff (data, not code: they differ only in their rates); Pool is
// priced from Standard by composition, and overrides the availability rule. The one switch left is
// the factory at the boundary, where a server code becomes a type.
import Foundation

public enum PolymorphicRideTypes {
    public struct Trip: Sendable, Equatable {
        public var metres: Int
        public var minutes: Int
        public var passengers: Int
        public var hasLuggage: Bool

        public init(metres: Int, minutes: Int, passengers: Int = 1, hasLuggage: Bool = false) {
            self.metres = metres
            self.minutes = minutes
            self.passengers = passengers
            self.hasLuggage = hasLuggage
        }
    }

    public protocol RideType: Sendable {
        var name: String { get }
        var seats: Int { get }
        func price(for trip: Trip) -> Int
        func isAvailable(for trip: Trip) -> Bool
    }

    public struct Quote: Sendable, Equatable, CustomStringConvertible {
        public let name: String
        public let price: Int

        public init(name: String, price: Int) {
            self.name = name
            self.price = price
        }

        public var description: String { "\(name) \(price)p" }
    }

    /// The usual way to price a ride: a base fare plus rates per kilometre and per minute, in
    /// pence, rounded down
    struct Tariff: Sendable {
        let base: Int
        let perKilometre: Int
        let perMinute: Int

        func price(for trip: Trip) -> Int {
            base + perKilometre * trip.metres / 1000 + perMinute * trip.minutes
        }
    }

    public struct Standard: RideType {
        static let tariff = Tariff(base: 250, perKilometre: 100, perMinute: 20)

        public init() {}
        public var name: String { "Standard" }
        public var seats: Int { 4 }

        public func price(for trip: Trip) -> Int {
            Self.tariff.price(for: trip)
        }
    }

    public struct XL: RideType {
        static let tariff = Tariff(base: 400, perKilometre: 150, perMinute: 25)

        public init() {}
        public var name: String { "XL" }
        public var seats: Int { 6 }

        public func price(for trip: Trip) -> Int {
            Self.tariff.price(for: trip)
        }
    }

    /// A shared ride: 40% off the Standard fare, for up to two people travelling light
    public struct Pool: RideType {
        public init() {}
        public var name: String { "Pool" }
        public var seats: Int { 2 }

        public func price(for trip: Trip) -> Int {
            Standard().price(for: trip) * 60 / 100
        }

        public func isAvailable(for trip: Trip) -> Bool {
            trip.passengers <= seats && !trip.hasLuggage
        }
    }

    public struct Lux: RideType {
        static let tariff = Tariff(base: 500, perKilometre: 300, perMinute: 40)
        static let minimumFare = 1500

        public init() {}
        public var name: String { "Lux" }
        public var seats: Int { 4 }

        public func price(for trip: Trip) -> Int {
            max(Self.minimumFare, Self.tariff.price(for: trip))
        }
    }

    public static func quotes(for trip: Trip, from rides: [any RideType]) -> [Quote] {
        rides
            .filter { $0.isAvailable(for: trip) }
            .map { Quote(name: $0.name, price: $0.price(for: trip)) }
            .sorted { ($0.price, $0.name) < ($1.price, $1.name) }
    }

    public static func ride(code: String) -> (any RideType)? {
        switch code {
        case "standard": Standard()
        case "xl": XL()
        case "pool": Pool()
        case "lux": Lux()
        default: nil
        }
    }
}

extension PolymorphicRideTypes.RideType {
    /// A requirement with a default, so a type that overrides it (Pool) is called through `any RideType` too
    public func isAvailable(for trip: PolymorphicRideTypes.Trip) -> Bool {
        trip.passengers <= seats
    }
}
