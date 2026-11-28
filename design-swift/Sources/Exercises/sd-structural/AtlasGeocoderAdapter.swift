// Kata: Adapt a geocoding SDK (D11 · Adapter: wrapping SDKs and legacy code)
import DesignKit
import Foundation

public enum AtlasGeocoderAdapter {
    // MARK: The vendor's SDK. You can't change any of this.

    /// A search result as the Atlas SDK reports it, with coordinates in millionths of a degree
    public struct AtlasPlacemark: Sendable {
        public let name: String?
        public let latitudeE6: Int
        public let longitudeE6: Int
        public let isoCountryCode: String?

        public init(name: String?, latitudeE6: Int, longitudeE6: Int, isoCountryCode: String?) {
            self.name = name
            self.latitudeE6 = latitudeE6
            self.longitudeE6 = longitudeE6
            self.isoCountryCode = isoCountryCode
        }
    }

    /// The SDK's only error: a number. 404 means nothing matched, 401 and 403 a bad API key, 429 too
    /// many requests, and -1009 no internet connection.
    public struct AtlasError: Error, Sendable {
        public let code: Int

        public init(code: Int) {
            self.code = code
        }
    }

    /// The SDK's geocoder. It calls `completion` once with results or an error, on a queue of its
    /// choosing, except for a known bug: it sometimes calls it a second time.
    public protocol AtlasGeocoding: Sendable {
        func geocode(_ query: String, completion: @escaping @Sendable ([AtlasPlacemark]?, AtlasError?) -> Void)
    }

    // MARK: Your app's interface. The rest of the app only ever sees these.

    public struct Place: Equatable, Sendable {
        public let name: String
        public let latitude: Double
        public let longitude: Double
        public let countryCode: String?

        public init(name: String, latitude: Double, longitude: Double, countryCode: String?) {
            self.name = name
            self.latitude = latitude
            self.longitude = longitude
            self.countryCode = countryCode
        }
    }

    public enum PlaceSearchError: Error, Equatable, Sendable {
        case offline
        case rateLimited
        case misconfigured
        case failed(code: Int)
    }

    public protocol PlaceSearching: Sendable {
        func places(matching query: String) async throws -> [Place]
    }

    // MARK: The adapter you write

    /// Lets the app search for places through the Atlas SDK, without the app knowing Atlas exists
    public struct AtlasPlaceSearch: PlaceSearching {
        private let geocoder: any AtlasGeocoding

        public init(geocoder: any AtlasGeocoding) {
            self.geocoder = geocoder
        }

        /// Places matching `query`, in the SDK's order. Throws only `PlaceSearchError`.
        public func places(matching query: String) async throws -> [Place] {
            // Write your solution here, then run:
            // swift test --filter AtlasGeocoderAdapterTests
            throw Unimplemented()
        }
    }
}
