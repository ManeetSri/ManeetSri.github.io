// Reference solution: endpoint rate limiter. Only the last `limit` allowed requests to an endpoint can
// ever matter, so each endpoint keeps exactly those in a ring buffer, oldest at `start`. A request is
// allowed if fewer than `limit` are stored, or if the oldest stored one has left the window
// (oldest ≤ time - window); then the new time overwrites the oldest. O(1) per call (plus the dictionary
// lookup), and O(limit) memory per endpoint however long the app runs.

public enum EndpointRateLimiter {
    public final class Limiter {
        /// The last `limit` allowed request times for one endpoint.
        private struct Recent {
            var times: [Int] = []   // grows to `limit`, then wraps around
            var start = 0           // index of the oldest time, once full

            mutating func admit(_ time: Int, limit: Int, window: Int) -> Bool {
                if times.count < limit {
                    times.append(time)
                    return true
                }
                guard times[start] <= time - window else { return false }
                times[start] = time
                start = (start + 1) % limit
                return true
            }

            func wait(at time: Int, limit: Int, window: Int) -> Int {
                guard times.count == limit else { return 0 }
                return max(0, times[start] + window - time)
            }
        }

        public let limit: Int
        public let window: Int
        private var recent: [String: Recent] = [:]

        public init(limit: Int, window: Int) {
            precondition(limit > 0 && window > 0, "A limiter needs a positive limit and window")
            self.limit = limit
            self.window = window
        }

        public func allow(_ endpoint: String, at time: Int) -> Bool {
            // Mutating through the default subscript changes the stored struct in place, with no copy
            recent[endpoint, default: Recent()].admit(time, limit: limit, window: window)
        }

        public func retryAfter(_ endpoint: String, at time: Int) -> Int {
            recent[endpoint]?.wait(at: time, limit: limit, window: window) ?? 0
        }
    }
}
