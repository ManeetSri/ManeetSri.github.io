import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ModellingRideTrackingTests {
    typealias RideStatus = ModellingRideTracking.RideStatus
    typealias Driver = ModellingRideTracking.Driver

    static let sam = Driver(name: "Sam", plate: "AB12 CDE")
    static let pickedUp = try! Date("2026-03-01T08:15:00Z", strategy: .iso8601)

    /// One of each status, in the order the JSON samples list them
    static let samples: [(json: String, status: RideStatus)] = [
        (#"{"status":"searching"}"#, .searching),
        (#"{"status":"driver_assigned","driver_name":"Sam","plate":"AB12 CDE","eta_minutes":4}"#, .driverAssigned(sam, etaMinutes: 4)),
        (#"{"status":"on_trip","driver_name":"Sam","plate":"AB12 CDE","started_at":"2026-03-01T08:15:00Z"}"#, .onTrip(sam, startedAt: pickedUp)),
        (#"{"status":"completed","fare_pence":1450}"#, .completed(farePence: 1450)),
        (#"{"status":"cancelled","cancelled_by":"driver"}"#, .cancelled(by: .driver)),
    ]

    private func decode(_ json: String) throws -> RideStatus {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(RideStatus.self, from: Data(json.utf8))
    }

    private func encode(_ status: RideStatus) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys
        return String(decoding: try encoder.encode(status), as: UTF8.self)
    }

    @Test("Decodes each status into the case that carries its data")
    func decodesEachStatus() throws {
        for sample in Self.samples {
            #expect(try decode(sample.json) == sample.status)
        }
    }

    @Test("Ignores fields that belong to other statuses, including nulls")
    func ignoresOtherFields() throws {
        #expect(try decode(#"{"status":"searching","driver_name":null,"eta_minutes":null}"#) == .searching)
        #expect(try decode(#"{"status":"cancelled","cancelled_by":"rider","eta_minutes":3}"#) == .cancelled(by: .rider))
        #expect(try decode(#"{"status":"completed","fare_pence":900,"driver_name":"Sam","plate":null}"#) == .completed(farePence: 900))
    }

    @Test("A status without the data it needs is rejected", arguments: [
        #"{"status":"driver_assigned","driver_name":"Sam","plate":"AB12 CDE"}"#,
        #"{"status":"driver_assigned","driver_name":"Sam","eta_minutes":4}"#,
        #"{"status":"driver_assigned","driver_name":"Sam","plate":"AB12 CDE","eta_minutes":null}"#,
        #"{"status":"on_trip","driver_name":"Sam","plate":"AB12 CDE"}"#,
        #"{"status":"completed"}"#,
        #"{"status":"cancelled"}"#,
        #"{"driver_name":"Sam"}"#,
    ])
    func rejectsMissingData(json: String) {
        #expect(throws: DecodingError.self) { try decode(json) }
    }

    @Test("Impossible values are rejected at the boundary", arguments: [
        #"{"status":"driver_assigned","driver_name":"  ","plate":"AB12 CDE","eta_minutes":4}"#,
        #"{"status":"driver_assigned","driver_name":"Sam","plate":"","eta_minutes":4}"#,
        #"{"status":"driver_assigned","driver_name":"Sam","plate":"AB12 CDE","eta_minutes":-1}"#,
        #"{"status":"completed","fare_pence":-50}"#,
        #"{"status":"cancelled","cancelled_by":"weather"}"#,
        #"{"status":"teleporting"}"#,
        #"{"status":"driver_assigned","driver_name":"Sam","plate":"AB12 CDE","eta_minutes":"4"}"#,
    ])
    func rejectsImpossibleValues(json: String) {
        #expect(throws: DecodingError.self) { try decode(json) }
    }

    @Test("Encodes the flat shape the server sends, with only that status's fields")
    func encodesFlatShape() throws {
        #expect(try encode(.searching) == #"{"status":"searching"}"#)
        #expect(try encode(.driverAssigned(Self.sam, etaMinutes: 4)) == #"{"driver_name":"Sam","eta_minutes":4,"plate":"AB12 CDE","status":"driver_assigned"}"#)
        #expect(try encode(.onTrip(Self.sam, startedAt: Self.pickedUp)) == #"{"driver_name":"Sam","plate":"AB12 CDE","started_at":"2026-03-01T08:15:00Z","status":"on_trip"}"#)
        #expect(try encode(.completed(farePence: 1450)) == #"{"fare_pence":1450,"status":"completed"}"#)
        #expect(try encode(.cancelled(by: .system)) == #"{"cancelled_by":"system","status":"cancelled"}"#)
    }

    @Test("Every status survives a round trip")
    func roundTrips() throws {
        for sample in Self.samples {
            #expect(try decode(encode(sample.status)) == sample.status)
        }
    }

    @Test("Questions about a status are answered for every case")
    func derivedQuestions() {
        let statuses = Self.samples.map(\.status)
        #expect(statuses.map(\.isLive) == [true, true, true, false, false])
        #expect(statuses.map(\.canCancel) == [true, true, false, false, false])
        #expect(statuses.map(\.driver) == [nil, Self.sam, Self.sam, nil, nil])
    }
}
