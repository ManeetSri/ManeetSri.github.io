// Kata: A ride's status as an enum (D02 · Making illegal states unrepresentable with enums)
import DesignKit
import Foundation

public enum ModellingRideTracking {
    /// The driver on their way to you, or driving you
    public struct Driver: Equatable, Sendable {
        public let name: String
        public let plate: String

        public init(name: String, plate: String) {
            self.name = name
            self.plate = plate
        }
    }

    /// Who called the ride off. The raw values are what the server sends.
    public enum CancelledBy: String, Equatable, Sendable {
        case rider
        case driver
        case system
    }

    /// Every state a ride can be in, each carrying exactly the data that state has.
    ///
    /// The server sends a flat JSON object: a `status` string plus whichever fields that status needs.
    ///
    ///     {"status": "searching"}
    ///     {"status": "driver_assigned", "driver_name": "Sam", "plate": "AB12 CDE", "eta_minutes": 4}
    ///     {"status": "on_trip", "driver_name": "Sam", "plate": "AB12 CDE", "started_at": "2026-03-01T08:15:00Z"}
    ///     {"status": "completed", "fare_pence": 1450}
    ///     {"status": "cancelled", "cancelled_by": "driver"}
    public enum RideStatus: Equatable, Sendable, Codable {
        case searching
        case driverAssigned(Driver, etaMinutes: Int)
        case onTrip(Driver, startedAt: Date)
        case completed(farePence: Int)
        case cancelled(by: CancelledBy)

        /// Decodes the flat JSON above. Fields that belong to other statuses are ignored. A missing field,
        /// an unknown status or an impossible value (a blank name or plate, a negative ETA or fare, an
        /// unknown `cancelled_by`) throws a `DecodingError`.
        public init(from decoder: any Decoder) throws {
            // Write your solution here, then run:
            // swift test --filter ModellingRideTrackingTests
            throw Unimplemented()
        }

        /// Encodes the same flat shape, with only this status's fields.
        public func encode(to encoder: any Encoder) throws {
            throw Unimplemented()
        }

        /// True while the ride is under way and the Live Activity should stay up: searching, a driver on
        /// the way, or on the trip.
        public var isLive: Bool {
            false
        }

        /// The rider can cancel until the trip starts.
        public var canCancel: Bool {
            false
        }

        /// The driver, in the statuses that have one.
        public var driver: Driver? {
            nil
        }
    }
}
