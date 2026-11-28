// Kata: An interceptor chain (D12 · Chain of responsibility: interceptors and middleware)
import DesignKit
import Foundation

public enum RequestRelay {
    /// The rest of the chain, as seen from one interceptor: call it to pass a request on
    public struct Next: Sendable {
        private let run: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

        public init(_ run: @escaping @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) {
            self.run = run
        }

        public func callAsFunction(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            try await run(request)
        }
    }

    /// One link in the chain. It may change the request, pass it on with `next` (once, several times, or
    /// not at all), and change or replace what comes back.
    public protocol Interceptor: Sendable {
        func intercept(_ request: URLRequest, next: Next) async throws -> (Data, HTTPURLResponse)
    }

    /// An HTTP client that runs each request through `interceptors`, first to last, and then `transport`.
    /// Responses come back through them in the opposite order.
    public struct Pipeline: HTTPClient {
        public init(_ interceptors: [any Interceptor], transport: any HTTPClient) {}

        public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            // Write your solution here, then run:
            // swift test --filter RequestRelayTests
            throw Unimplemented()
        }
    }

    /// Adds a header to every request that doesn't already set it
    public struct DefaultHeader: Interceptor {
        public init(_ name: String, _ value: String) {}

        public func intercept(_ request: URLRequest, next: Next) async throws -> (Data, HTTPURLResponse) {
            throw Unimplemented()
        }
    }

    /// Sends `Authorization: Bearer <token>`. When the response is a 401, it asks `refresh` for a new token
    /// and sends the request once more with it, returning whatever that second attempt gets.
    public struct BearerAuth: Interceptor {
        public init(token: @escaping @Sendable () async throws -> String, refresh: @escaping @Sendable () async throws -> String) {}

        public func intercept(_ request: URLRequest, next: Next) async throws -> (Data, HTTPURLResponse) {
            throw Unimplemented()
        }
    }
}
