// Reference solution: Delivery tracker. Each type answers from its own stored properties and talks only
// to the one below it, so the tracking card only ever talks to the order.
import Foundation

public enum CouplingDeliveryTracker {
    public struct Point: Equatable, Sendable {
        public let x: Double
        public let y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }

        public func distance(to other: Point) -> Double {
            ((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y)).squareRoot()
        }
    }

    public enum VehicleKind: Sendable {
        case bicycle
        case scooter
        case car
    }

    public struct Vehicle: Sendable {
        private let kind: VehicleKind

        public init(kind: VehicleKind) {
            self.kind = kind
        }

        private var metresPerMinute: Double {
            switch kind {
            case .bicycle: 250
            case .scooter: 400
            case .car: 500
            }
        }

        public func minutes(toTravel metres: Double) -> Int {
            Int((max(0, metres) / metresPerMinute).rounded(.up))
        }
    }

    public struct Courier: Sendable {
        public let name: String
        private let vehicle: Vehicle
        private let location: Point

        public init(name: String, vehicle: Vehicle, location: Point) {
            self.name = name
            self.vehicle = vehicle
            self.location = location
        }

        public func minutes(to destination: Point) -> Int {
            vehicle.minutes(toTravel: location.distance(to: destination))
        }
    }

    public enum Stage: Sendable {
        case preparing(readyInMinutes: Int)
        case onTheWay(Courier)
        case delivered
    }

    public enum ETA: Equatable, Sendable {
        case preparing(readyInMinutes: Int)
        case arriving(courierName: String, minutes: Int)
        case arrivingNow(courierName: String)
        case delivered
    }

    public struct Order: Sendable {
        private let stage: Stage
        private let destination: Point

        public init(stage: Stage, destination: Point) {
            self.stage = stage
            self.destination = destination
        }

        public func eta() -> ETA {
            switch stage {
            case .preparing(let minutes):
                return .preparing(readyInMinutes: minutes)
            case .onTheWay(let courier):
                let minutes = courier.minutes(to: destination)
                return minutes <= 1 ? .arrivingNow(courierName: courier.name) : .arriving(courierName: courier.name, minutes: minutes)
            case .delivered:
                return .delivered
            }
        }
    }

    public enum TrackingCard {
        public static func text(for order: Order) -> String {
            switch order.eta() {
            case .preparing(let minutes) where minutes <= 0: "Almost ready"
            case .preparing(let minutes): "Being prepared, ready in \(minutes) min"
            case .arriving(let name, let minutes): "\(name) is \(minutes) min away"
            case .arrivingNow(let name): "\(name) is arriving now"
            case .delivered: "Delivered"
            }
        }
    }
}
