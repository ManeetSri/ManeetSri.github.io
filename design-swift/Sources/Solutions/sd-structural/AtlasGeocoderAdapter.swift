// Reference solution: Adapt a geocoding SDK. The adapter is the only type that knows Atlas exists: it
// turns the callback into async/await (resuming once, however often the SDK calls back), converts
// microdegrees to degrees, and maps the SDK's error codes onto the app's own errors.
import Foundation
import Synchronization

public enum AtlasGeocoderAdapter {
    // MARK: The vendor's SDK

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

    public struct AtlasError: Error, Sendable {
        public let code: Int

        public init(code: Int) {
            self.code = code
        }
    }

    public protocol AtlasGeocoding: Sendable {
        func geocode(_ query: String, completion: @escaping @Sendable ([AtlasPlacemark]?, AtlasError?) -> Void)
    }

    // MARK: Your app's interface

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

    // MARK: The adapter

    public struct AtlasPlaceSearch: PlaceSearching {
        private let geocoder: any AtlasGeocoding

        public init(geocoder: any AtlasGeocoding) {
            self.geocoder = geocoder
        }

        public func places(matching query: String) async throws -> [Place] {
            let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else { return [] }
            let placemarks: [AtlasPlacemark] = try await withCheckedThrowingContinuation { continuation in
                let callback = FirstCallback(continuation)
                geocoder.geocode(query) { placemarks, error in
                    callback.resume(with: Self.outcome(placemarks, error))
                }
            }
            return placemarks.compactMap(Self.place(from:))
        }

        /// What the SDK's answer means for the app. An error wins over results; "nothing found" isn't an error.
        private static func outcome(_ placemarks: [AtlasPlacemark]?, _ error: AtlasError?) -> Result<[AtlasPlacemark], PlaceSearchError> {
            if let error {
                switch error.code {
                case 404: return .success([])
                case 401, 403: return .failure(.misconfigured)
                case 429: return .failure(.rateLimited)
                case -1009: return .failure(.offline)
                default: return .failure(.failed(code: error.code))
                }
            }
            guard let placemarks else { return .failure(.failed(code: 0)) }
            return .success(placemarks)
        }

        private static func place(from placemark: AtlasPlacemark) -> Place? {
            guard let name = placemark.name, !name.isEmpty else { return nil }
            return Place(
                name: name,
                latitude: Double(placemark.latitudeE6) / 1_000_000,
                longitude: Double(placemark.longitudeE6) / 1_000_000,
                countryCode: placemark.isoCountryCode?.uppercased()
            )
        }
    }

    /// Resumes a continuation on the first callback and ignores the rest: resuming a checked
    /// continuation twice crashes the app
    private final class FirstCallback: Sendable {
        private let continuation: Mutex<CheckedContinuation<[AtlasPlacemark], any Error>?>

        init(_ continuation: CheckedContinuation<[AtlasPlacemark], any Error>) {
            self.continuation = Mutex(continuation)
        }

        func resume(with outcome: Result<[AtlasPlacemark], PlaceSearchError>) {
            let pending = continuation.withLock { pending in
                defer { pending = nil }
                return pending
            }
            pending?.resume(with: outcome)
        }
    }
}
