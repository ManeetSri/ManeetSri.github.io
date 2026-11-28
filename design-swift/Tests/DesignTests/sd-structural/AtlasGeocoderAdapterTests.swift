import DesignKit
import Foundation
import Synchronization
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct AtlasGeocoderAdapterTests {
    typealias Kata = AtlasGeocoderAdapter
    typealias Placemark = AtlasGeocoderAdapter.AtlasPlacemark
    typealias Place = AtlasGeocoderAdapter.Place

    /// A scripted Atlas SDK: it makes each callback it's given, in order, and records every query
    final class FakeAtlas: AtlasGeocoderAdapter.AtlasGeocoding {
        typealias Callback = (placemarks: [Placemark]?, error: AtlasGeocoderAdapter.AtlasError?)

        private let callbacks: [Callback]
        private let onAnotherQueue: Bool
        private let queries = Mutex<[String]>([])

        init(_ callbacks: Callback..., onAnotherQueue: Bool = false) {
            self.callbacks = callbacks
            self.onAnotherQueue = onAnotherQueue
        }

        var received: [String] { queries.withLock { $0 } }

        func geocode(_ query: String, completion: @escaping @Sendable ([Placemark]?, AtlasGeocoderAdapter.AtlasError?) -> Void) {
            queries.withLock { $0.append(query) }
            let callbacks = self.callbacks
            if onAnotherQueue {
                DispatchQueue.global().async {
                    callbacks.forEach { completion($0.placemarks, $0.error) }
                }
            } else {
                callbacks.forEach { completion($0.placemarks, $0.error) }
            }
        }
    }

    private let leeds = Placemark(name: "Leeds", latitudeE6: 53_800_755, longitudeE6: -1_549_077, isoCountryCode: "gb")
    private let york = Placemark(name: "York", latitudeE6: 53_959_965, longitudeE6: -1_087_298, isoCountryCode: nil)

    private func adapter(_ sdk: FakeAtlas) -> Kata.AtlasPlaceSearch {
        Kata.AtlasPlaceSearch(geocoder: sdk)
    }

    @Test("Turns placemarks into places: degrees, and upper-case country codes")
    func converts() async throws {
        let places = try await adapter(FakeAtlas(([leeds, york], nil))).places(matching: "Leeds")
        #expect(places == [
            Place(name: "Leeds", latitude: 53.800755, longitude: -1.549077, countryCode: "GB"),
            Place(name: "York", latitude: 53.959965, longitude: -1.087298, countryCode: nil),
        ])
    }

    @Test("Leaves out results without a name")
    func dropsNameless() async throws {
        let nameless = Placemark(name: nil, latitudeE6: 0, longitudeE6: 0, isoCountryCode: "gb")
        let blank = Placemark(name: "", latitudeE6: 1, longitudeE6: 1, isoCountryCode: "gb")
        let places = try await adapter(FakeAtlas(([nameless, leeds, blank], nil))).places(matching: "Leeds")
        #expect(places.map(\.name) == ["Leeds"])
    }

    @Test("Sends the SDK a trimmed query, and never a blank one")
    func trimsQueries() async throws {
        let sdk = FakeAtlas(([leeds], nil))
        let search = adapter(sdk)
        #expect(try await search.places(matching: "  Leeds \n").count == 1)
        #expect(sdk.received == ["Leeds"])
        #expect(try await search.places(matching: "   ").isEmpty)
        #expect(sdk.received == ["Leeds"])
    }

    @Test("Nothing found is an empty list, whichever way the SDK says it")
    func nothingFound() async throws {
        #expect(try await adapter(FakeAtlas((nil, .init(code: 404)))).places(matching: "Atlantis").isEmpty)
        #expect(try await adapter(FakeAtlas(([], nil))).places(matching: "Atlantis").isEmpty)
    }

    @Test("Maps the SDK's error codes onto the app's errors", arguments: [
        (401, Kata.PlaceSearchError.misconfigured),
        (403, .misconfigured),
        (429, .rateLimited),
        (-1009, .offline),
        (500, .failed(code: 500)),
    ])
    func mapsErrors(code: Int, expected: Kata.PlaceSearchError) async {
        let search = adapter(FakeAtlas((nil, .init(code: code))))
        await #expect(throws: expected) {
            try await search.places(matching: "Leeds")
        }
    }

    @Test("An error wins over results, and an empty answer is a failure")
    func oddAnswers() async {
        await #expect(throws: Kata.PlaceSearchError.rateLimited) {
            try await adapter(FakeAtlas(([leeds], .init(code: 429)))).places(matching: "Leeds")
        }
        await #expect(throws: Kata.PlaceSearchError.failed(code: 0)) {
            try await adapter(FakeAtlas((nil, nil))).places(matching: "Leeds")
        }
    }

    @Test("Uses the first callback when the SDK calls back twice")
    func firstCallbackWins() async throws {
        let places = try await adapter(FakeAtlas(([leeds], nil), ([york], nil))).places(matching: "Leeds")
        #expect(places.map(\.name) == ["Leeds"])
        await #expect(throws: Kata.PlaceSearchError.offline) {
            try await adapter(FakeAtlas((nil, .init(code: -1009)), ([york], nil))).places(matching: "York")
        }
    }

    @Test("Works when the SDK calls back on a queue of its own")
    func anotherQueue() async throws {
        let sdk = FakeAtlas(([york], nil), ([leeds], nil), onAnotherQueue: true)
        let places = try await adapter(sdk).places(matching: "York")
        #expect(places.map(\.name) == ["York"])
    }
}
