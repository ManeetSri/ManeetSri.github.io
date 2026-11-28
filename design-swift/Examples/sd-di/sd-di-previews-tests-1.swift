// Generated from src/dsa/design/content/lessons/sd-di/sd-di-previews-tests.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Trip: Codable, Equatable, Sendable {
    let id: String
    let departure: Int
}

protocol TripStore {
    func save(_ trip: Trip) throws
    func all() throws -> [Trip]
}

/// The fake: quick, in memory, and quietly out of date
final class InMemoryTripStore: TripStore {
    private var trips: [Trip] = []
    func save(_ trip: Trip) { trips.append(trip) }
    func all() -> [Trip] { trips }
}

/// The real store: a JSON file, sorted by departure, as the app relies on
final class FileTripStore: TripStore {
    private let url: URL

    init(directory: URL) {
        url = directory.appending(path: "trips.json")
    }

    func save(_ trip: Trip) throws {
        let trips = (try all()) + [trip]
        try JSONEncoder().encode(trips.sorted { $0.departure < $1.departure }).write(to: url, options: .atomic)
    }

    func all() throws -> [Trip] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        return try JSONDecoder().decode([Trip].self, from: data)
    }
}

/// The contract every TripStore must meet
func checkContract(_ name: String, _ makeStore: () throws -> any TripStore) throws {
    let store = try makeStore()
    try store.save(Trip(id: "OPO", departure: 20))
    try store.save(Trip(id: "LIS", departure: 10))
    let ids = try store.all().map(\.id)
    let keepsEverything = Set(ids) == ["OPO", "LIS"]
    let sortedByDeparture = ids == ["LIS", "OPO"]
    print("\(name): keeps every trip \(keepsEverything ? "ok" : "FAILED"); sorted by departure \(sortedByDeparture ? "ok" : "FAILED")")
}

let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: folder) }

try checkContract("InMemoryTripStore") { InMemoryTripStore() }
try checkContract("FileTripStore") { FileTripStore(directory: folder) }
