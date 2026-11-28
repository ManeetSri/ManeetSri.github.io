// Reference solution: An interceptor chain. The pipeline folds the interceptors into one `Next`, starting
// from the transport and wrapping it from the last interceptor to the first, so the first one runs
// outermost. Each interceptor only knows `next`, never the rest of the chain.
import DesignKit
import Foundation

public enum RequestRelay {
    public struct Next: Sendable {
        private let run: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

        public init(_ run: @escaping @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) {
            self.run = run
        }

        public func callAsFunction(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            try await run(request)
        }
    }

    public protocol Interceptor: Sendable {
        func intercept(_ request: URLRequest, next: Next) async throws -> (Data, HTTPURLResponse)
    }

    public struct Pipeline: HTTPClient {
        private let chain: Next

        public init(_ interceptors: [any Interceptor], transport: any HTTPClient) {
            let last = Next { request in try await transport.send(request) }
            chain = interceptors.reversed().reduce(last) { next, interceptor in
                Next { request in try await interceptor.intercept(request, next: next) }
            }
        }

        public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            try await chain(request)
        }
    }

    public struct DefaultHeader: Interceptor {
        private let name: String
        private let value: String

        public init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }

        public func intercept(_ request: URLRequest, next: Next) async throws -> (Data, HTTPURLResponse) {
            guard request.value(forHTTPHeaderField: name) == nil else { return try await next(request) }
            var request = request
            request.setValue(value, forHTTPHeaderField: name)
            return try await next(request)
        }
    }

    public struct BearerAuth: Interceptor {
        private let token: @Sendable () async throws -> String
        private let refresh: @Sendable () async throws -> String

        public init(token: @escaping @Sendable () async throws -> String, refresh: @escaping @Sendable () async throws -> String) {
            self.token = token
            self.refresh = refresh
        }

        public func intercept(_ request: URLRequest, next: Next) async throws -> (Data, HTTPURLResponse) {
            let first = try await next(signed(request, with: token()))
            guard first.1.statusCode == 401 else { return first }
            return try await next(signed(request, with: refresh()))
        }

        private func signed(_ request: URLRequest, with token: String) -> URLRequest {
            var request = request
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
    }
}
