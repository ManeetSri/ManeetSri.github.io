// Kata: Ride types, replacing a conditional with polymorphism (D15 · Replace conditional with polymorphism)
import Foundation

public enum PolymorphicRideTypes {
    /// A journey someone wants a price for
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

    /// One kind of ride. Each type owns its rules, so a new kind of ride is a new type rather than
    /// an edit to every switch in the app.
    public protocol RideType: Sendable {
        /// The name shown in the ride picker
        var name: String { get }
        /// How many passengers it can take
        var seats: Int { get }
        /// The fare for a trip, in pence
        func price(for trip: Trip) -> Int
        /// Whether it can take this trip. Most rides only need a seat for everyone.
        func isAvailable(for trip: Trip) -> Bool
    }

    /// One line in the ride picker
    public struct Quote: Sendable, Equatable, CustomStringConvertible {
        public let name: String
        public let price: Int

        public init(name: String, price: Int) {
            self.name = name
            self.price = price
        }

        public var description: String { "\(name) \(price)p" }
    }

    // The name and seats switches have already been moved into the types. Move the prices and
    // the availability rules next.

    public struct Standard: RideType {
        public init() {}
        public var name: String { "Standard" }
        public var seats: Int { 4 }

        public func price(for trip: Trip) -> Int {
            // Write your solution here, then run:
            // swift test --filter PolymorphicRideTypesTests
            return 0
        }
    }

    public struct XL: RideType {
        public init() {}
        public var name: String { "XL" }
        public var seats: Int { 6 }

        public func price(for trip: Trip) -> Int {
            return 0
        }
    }

    public struct Pool: RideType {
        public init() {}
        public var name: String { "Pool" }
        public var seats: Int { 2 }

        public func price(for trip: Trip) -> Int {
            return 0
        }
    }

    public struct Lux: RideType {
        public init() {}
        public var name: String { "Lux" }
        public var seats: Int { 4 }

        public func price(for trip: Trip) -> Int {
            return 0
        }
    }

    /// The ride picker: every ride that can take the trip, cheapest first, with equal prices in
    /// name order. It must work for any `RideType`, including ones it has never heard of.
    public static func quotes(for trip: Trip, from rides: [any RideType]) -> [Quote] {
        return []
    }

    /// The ride type for a code the server sends ("standard", "xl", "pool" or "lux"), or nil for a
    /// code this version of the app doesn't know
    public static func ride(code: String) -> (any RideType)? {
        return nil
    }
}

extension PolymorphicRideTypes.RideType {
    /// The usual rule: a seat for every passenger
    public func isAvailable(for trip: PolymorphicRideTypes.Trip) -> Bool {
        return false
    }
}
