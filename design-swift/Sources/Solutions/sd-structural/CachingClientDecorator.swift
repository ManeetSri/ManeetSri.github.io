// Reference solution: A caching decorator. It has the same interface as the client it wraps, so it
// slots in anywhere an HTTPClient goes. Only successful GETs are stored, keyed by URL and stamped with
// the clock's time; anything that might change a resource goes straight through and drops its entry.
import DesignKit
import Foundation

public enum CachingClientDecorator {
    public actor CachingHTTPClient<C: Clock>: HTTPClient where C.Duration == Swift.Duration {
        private struct Entry {
            let data: Data
            let response: HTTPURLResponse
            let storedAt: C.Instant
        }

        private let base: any HTTPClient
        private let ttl: Swift.Duration
        private let clock: C
        private var entries: [String: Entry] = [:]

        public init(wrapping base: any HTTPClient, ttl: Swift.Duration, clock: C) {
            self.base = base
            self.ttl = ttl
            self.clock = clock
        }

        public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            guard let key = request.url?.absoluteString else { return try await base.send(request) }
            guard (request.httpMethod ?? "GET").uppercased() == "GET" else {
                // A POST, PUT, PATCH or DELETE may change the resource, so its cached copy is suspect
                entries[key] = nil
                return try await base.send(request)
            }
            if request.cachePolicy != .reloadIgnoringLocalCacheData, let entry = entries[key] {
                if entry.storedAt.duration(to: clock.now) < ttl { return (entry.data, entry.response) }
                entries[key] = nil
            }
            // The actor is free while this awaits, so two misses for one URL can both reach the network.
            // That's correct, only wasteful: single-flight (D14) fixes it.
            let (data, response) = try await base.send(request)
            if (200..<300).contains(response.statusCode) {
                entries[key] = Entry(data: data, response: response, storedAt: clock.now)
            }
            return (data, response)
        }

        public func removeAll() {
            entries.removeAll()
        }
    }
}
