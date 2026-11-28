// Problem: Endpoint rate limiter (M71 · iOS-flavoured DSA questions)

public enum EndpointRateLimiter {
    /// Lets at most `limit` requests to each endpoint through in any `window` milliseconds. A request at
    /// `time` counts the allowed requests to the same endpoint at times `s` with `time - window < s ≤ time`.
    /// Rejected requests aren't recorded. Times never decrease from one call to the next.
    public final class Limiter {
        public let limit: Int
        public let window: Int

        public init(limit: Int, window: Int) {
            self.limit = limit
            self.window = window
        }

        /// Returns true, and records the request, if a request to `endpoint` at `time` may go ahead.
        public func allow(_ endpoint: String, at time: Int) -> Bool {
            // Write your solution here, then run:
            // swift test --filter EndpointRateLimiterTests
            return false
        }

        /// How many milliseconds after `time` a request to `endpoint` would next be allowed: 0 if one
        /// would be allowed right now. Records nothing.
        public func retryAfter(_ endpoint: String, at time: Int) -> Int {
            return -1
        }
    }
}
