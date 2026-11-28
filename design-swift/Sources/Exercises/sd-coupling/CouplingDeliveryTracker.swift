// Kata: Delivery tracker (D03 · The Law of Demeter and tell, don't ask)
import DesignKit
import Foundation

public enum CouplingDeliveryTracker {
    /// A position on the delivery area's map, in metres. Already written for you.
    public struct Point: Equatable, Sendable {
        public let x: Double
        public let y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }

        /// The straight-line distance in metres
        public func distance(to other: Point) -> Double {
            ((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y)).squareRoot()
        }
    }

    public enum VehicleKind: Sendable {
        case bicycle
        case scooter
        case car
    }

    /// Knows how fast it goes. Nobody outside can read its kind: ask it a question instead.
    public struct Vehicle: Sendable {
        private let kind: VehicleKind

        public init(kind: VehicleKind) {
            self.kind = kind
        }

        /// Whole minutes to travel `metres`, rounded up. A bicycle covers 250 m a minute, a scooter 400 and
        /// a car 500. No distance takes no time.
        public func minutes(toTravel metres: Double) -> Int {
            // Write your solution here, then run:
            // swift test --filter CouplingDeliveryTrackerTests
            return 0
        }
    }

    /// Knows where they are and what they ride. Only their name is public.
    public struct Courier: Sendable {
        public let name: String
        private let vehicle: Vehicle
        private let location: Point

        public init(name: String, vehicle: Vehicle, location: Point) {
            self.name = name
            self.vehicle = vehicle
            self.location = location
        }

        /// Minutes from where the courier is now to `destination`, on their own vehicle
        public func minutes(to destination: Point) -> Int {
            // Write your solution here
            return 0
        }
    }

    /// Where an order has got to
    public enum Stage: Sendable {
        case preparing(readyInMinutes: Int)
        case onTheWay(Courier)
        case delivered
    }

    /// Everything the tracking screen needs to know, and nothing about how it was worked out
    public enum ETA: Equatable, Sendable {
        case preparing(readyInMinutes: Int)
        case arriving(courierName: String, minutes: Int)
        /// The courier is a minute away or less
        case arrivingNow(courierName: String)
        case delivered
    }

    /// Knows its stage and where it's going. Neither is public.
    public struct Order: Sendable {
        private let stage: Stage
        private let destination: Point

        public init(stage: Stage, destination: Point) {
            self.stage = stage
            self.destination = destination
        }

        /// Preparing: how long until it's ready. On the way: the courier's minutes to the destination, or
        /// `arrivingNow` at 1 minute or less. Delivered: `delivered`.
        public func eta() -> ETA {
            // Write your solution here
            return .delivered
        }
    }

    /// The line of text on the order screen. Talks only to the order.
    public enum TrackingCard {
        /// - Preparing: "Being prepared, ready in 12 min", or "Almost ready" at 0 minutes or less
        /// - Arriving: "Sam is 13 min away"
        /// - Arriving now: "Sam is arriving now"
        /// - Delivered: "Delivered"
        public static func text(for order: Order) -> String {
            // Write your solution here
            return ""
        }
    }
}
