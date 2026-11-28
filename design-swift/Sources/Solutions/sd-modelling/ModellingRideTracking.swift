// Reference solution: A ride's status as an enum. The flat JSON is parsed once, at the boundary, into a
// case that carries exactly its own data; every question after that is an exhaustive switch.
import Foundation

public enum ModellingRideTracking {
    public struct Driver: Equatable, Sendable {
        public let name: String
        public let plate: String

        public init(name: String, plate: String) {
            self.name = name
            self.plate = plate
        }
    }

    public enum CancelledBy: String, Equatable, Sendable {
        case rider
        case driver
        case system
    }

    public enum RideStatus: Equatable, Sendable, Codable {
        case searching
        case driverAssigned(Driver, etaMinutes: Int)
        case onTrip(Driver, startedAt: Date)
        case completed(farePence: Int)
        case cancelled(by: CancelledBy)

        private enum CodingKeys: String, CodingKey {
            case status
            case driverName = "driver_name"
            case plate
            case etaMinutes = "eta_minutes"
            case startedAt = "started_at"
            case farePence = "fare_pence"
            case cancelledBy = "cancelled_by"
        }

        private typealias Container = KeyedDecodingContainer<CodingKeys>

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let status = try container.decode(String.self, forKey: .status)
            // Each status reads only its own fields, so leftovers from other statuses (often nulls) are ignored
            switch status {
            case "searching":
                self = .searching
            case "driver_assigned":
                self = .driverAssigned(try Self.driver(in: container), etaMinutes: try Self.nonNegative(.etaMinutes, in: container))
            case "on_trip":
                self = .onTrip(try Self.driver(in: container), startedAt: try container.decode(Date.self, forKey: .startedAt))
            case "completed":
                self = .completed(farePence: try Self.nonNegative(.farePence, in: container))
            case "cancelled":
                let raw = try container.decode(String.self, forKey: .cancelledBy)
                guard let cancelledBy = CancelledBy(rawValue: raw) else {
                    throw DecodingError.dataCorruptedError(forKey: .cancelledBy, in: container, debugDescription: "Unknown cancelled_by \"\(raw)\"")
                }
                self = .cancelled(by: cancelledBy)
            default:
                // An app that's a version behind sees a status it doesn't know: the caller keeps the last one it understood
                throw DecodingError.dataCorruptedError(forKey: .status, in: container, debugDescription: "Unknown status \"\(status)\"")
            }
        }

        private static func driver(in container: Container) throws -> Driver {
            Driver(name: try nonBlank(.driverName, in: container), plate: try nonBlank(.plate, in: container))
        }

        private static func nonBlank(_ key: CodingKeys, in container: Container) throws -> String {
            let value = try container.decode(String.self, forKey: key)
            guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "\(key.stringValue) is blank")
            }
            return value
        }

        private static func nonNegative(_ key: CodingKeys, in container: Container) throws -> Int {
            let value = try container.decode(Int.self, forKey: key)
            guard value >= 0 else {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "\(key.stringValue) is negative")
            }
            return value
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .searching:
                try container.encode("searching", forKey: .status)
            case let .driverAssigned(driver, etaMinutes):
                try container.encode("driver_assigned", forKey: .status)
                try container.encode(driver.name, forKey: .driverName)
                try container.encode(driver.plate, forKey: .plate)
                try container.encode(etaMinutes, forKey: .etaMinutes)
            case let .onTrip(driver, startedAt):
                try container.encode("on_trip", forKey: .status)
                try container.encode(driver.name, forKey: .driverName)
                try container.encode(driver.plate, forKey: .plate)
                try container.encode(startedAt, forKey: .startedAt)
            case let .completed(farePence):
                try container.encode("completed", forKey: .status)
                try container.encode(farePence, forKey: .farePence)
            case let .cancelled(cancelledBy):
                try container.encode("cancelled", forKey: .status)
                try container.encode(cancelledBy.rawValue, forKey: .cancelledBy)
            }
        }

        public var isLive: Bool {
            switch self {
            case .searching, .driverAssigned, .onTrip: true
            case .completed, .cancelled: false
            }
        }

        public var canCancel: Bool {
            switch self {
            case .searching, .driverAssigned: true
            case .onTrip, .completed, .cancelled: false
            }
        }

        public var driver: Driver? {
            switch self {
            case let .driverAssigned(driver, _), let .onTrip(driver, _): driver
            case .searching, .completed, .cancelled: nil
            }
        }
    }
}
