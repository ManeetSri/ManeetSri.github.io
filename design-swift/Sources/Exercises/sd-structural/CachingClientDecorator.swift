// Kata: A caching decorator (D11 · Decorator: logging and caching by wrapping)
import DesignKit
import Foundation

public enum CachingClientDecorator {
    /// An HTTPClient that wraps another and answers repeated GET requests from memory while their
    /// responses are fresh. Callers can't tell it from the client it wraps, except that it's faster.
    public actor CachingHTTPClient<C: Clock>: HTTPClient where C.Duration == Swift.Duration {
        private let base: any HTTPClient
        private let ttl: Swift.Duration
        private let clock: C

        /// - Parameters:
        ///   - base: the client that really sends requests
        ///   - ttl: how long a response stays fresh, from when it arrived
        ///   - clock: where the time comes from (a `TestClock` in tests)
        public init(wrapping base: any HTTPClient, ttl: Swift.Duration, clock: C) {
            self.base = base
            self.ttl = ttl
            self.clock = clock
        }

        public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            // Write your solution here, then run:
            // swift test --filter CachingClientDecoratorTests
            throw Unimplemented()
        }

        /// Forgets every cached response: call it when the user signs out
        public func removeAll() {}
    }
}
