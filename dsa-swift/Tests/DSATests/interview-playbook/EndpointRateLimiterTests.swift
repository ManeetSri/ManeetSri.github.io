import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same requests
private struct LimiterRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// The obvious model: keep every allowed time per endpoint (sorted, because time never goes back) and
/// binary search for how many are still inside the window.
private final class LimiterModel {
    let limit: Int
    let window: Int
    private var allowed: [String: [Int]] = [:]

    init(limit: Int, window: Int) {
        self.limit = limit
        self.window = window
    }

    /// The index of the first time greater than `time - window`, so everything from there on is inside
    private func firstInside(_ times: [Int], at time: Int) -> Int {
        var low = 0, high = times.count
        while low < high {
            let mid = (low + high) / 2
            if times[mid] > time - window { high = mid } else { low = mid + 1 }
        }
        return low
    }

    /// How many allowed requests to `endpoint` are inside the window ending at `time`
    private func inside(_ endpoint: String, at time: Int) -> Int {
        let times = allowed[endpoint, default: []]
        return times.count - firstInside(times, at: time)
    }

    func allow(_ endpoint: String, at time: Int) -> Bool {
        guard inside(endpoint, at: time) < limit else { return false }
        allowed[endpoint, default: []].append(time)
        return true
    }

    func retryAfter(_ endpoint: String, at time: Int) -> Int {
        guard inside(endpoint, at: time) >= limit, let times = allowed[endpoint] else { return 0 }
        // The request that has to leave is the one `limit` places from the end
        return times[times.count - limit] + window - time
    }
}

@Suite struct EndpointRateLimiterTests {
    @Test("The example from the statement")
    func example() {
        let limiter = EndpointRateLimiter.Limiter(limit: 2, window: 1_000)
        #expect(limiter.allow("/feed", at: 0))
        #expect(limiter.allow("/feed", at: 400))
        #expect(!limiter.allow("/feed", at: 999))
        #expect(limiter.retryAfter("/feed", at: 999) == 1)
        #expect(limiter.allow("/feed", at: 1_000), "the request at 0 has just left the window")
        #expect(limiter.allow("/search", at: 1_000), "each endpoint has its own window")
        #expect(!limiter.allow("/feed", at: 1_300))
        #expect(limiter.retryAfter("/feed", at: 1_300) == 100)
        #expect(limiter.allow("/feed", at: 1_400))
    }

    @Test("retryAfter is 0 for an unknown endpoint and records nothing")
    func retryRecordsNothing() {
        let limiter = EndpointRateLimiter.Limiter(limit: 1, window: 50)
        #expect(limiter.retryAfter("/avatar", at: 10) == 0)
        #expect(limiter.retryAfter("/avatar", at: 10) == 0)
        #expect(limiter.allow("/avatar", at: 10))
        #expect(limiter.retryAfter("/avatar", at: 10) == 50)
        #expect(limiter.retryAfter("/avatar", at: 59) == 1)
        #expect(limiter.retryAfter("/avatar", at: 60) == 0)
        #expect(limiter.retryAfter("/avatar", at: 60) == 0, "asking twice doesn't use the slot")
        #expect(limiter.allow("/avatar", at: 60))
    }

    @Test("Rejected requests don't count against the window")
    func rejectedNotRecorded() {
        let limiter = EndpointRateLimiter.Limiter(limit: 1, window: 100)
        #expect(limiter.allow("/like", at: 0))
        for time in stride(from: 10, to: 100, by: 10) {
            #expect(!limiter.allow("/like", at: time))
        }
        // Only the request at 0 was recorded, so at 100 the window is empty again
        #expect(limiter.allow("/like", at: 100))
        #expect(!limiter.allow("/like", at: 199))
        #expect(limiter.allow("/like", at: 200))
    }

    @Test("Many requests at the same millisecond")
    func sameMillisecond() {
        let limiter = EndpointRateLimiter.Limiter(limit: 3, window: 10)
        let results = (0..<5).map { _ in limiter.allow("/sync", at: 7) }
        #expect(results == [true, true, true, false, false])
        #expect(limiter.retryAfter("/sync", at: 7) == 10)
        #expect(!limiter.allow("/sync", at: 16))
        let later = (0..<4).map { _ in limiter.allow("/sync", at: 17) }
        #expect(later == [true, true, true, false])
    }

    @Test("Matches the model on random request streams", arguments: [(1, 5), (2, 10), (3, 7), (5, 100), (8, 3)])
    func matchesModel(limit: Int, window: Int) {
        var random = LimiterRandom(seed: UInt64(limit * 1_000 + window))
        let endpoints = ["/feed", "/search", "/profile", "/upload"]
        let limiter = EndpointRateLimiter.Limiter(limit: limit, window: window)
        let model = LimiterModel(limit: limit, window: window)
        var time = 0
        var firstMismatch: String? = nil
        for step in 0..<3_000 where firstMismatch == nil {
            time += Int.random(in: 0...4, using: &random)
            let endpoint = endpoints[Int.random(in: 0..<endpoints.count, using: &random)]
            if Int.random(in: 0..<4, using: &random) == 0 {
                let got = limiter.retryAfter(endpoint, at: time), expected = model.retryAfter(endpoint, at: time)
                if got != expected { firstMismatch = "step \(step): retryAfter(\(endpoint), at: \(time)) gave \(got), expected \(expected)" }
            } else {
                let got = limiter.allow(endpoint, at: time), expected = model.allow(endpoint, at: time)
                if got != expected { firstMismatch = "step \(step): allow(\(endpoint), at: \(time)) gave \(got), expected \(expected)" }
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("200,000 requests across 500 endpoints")
    func large() {
        var random = LimiterRandom(seed: 71)
        let endpoints = (0..<500).map { "/api/v2/item/\($0)" }
        let limiter = EndpointRateLimiter.Limiter(limit: 40, window: 5_000)
        let model = LimiterModel(limit: 40, window: 5_000)
        var time = 1_000_000_000_000
        var firstMismatch: Int? = nil
        var allowedCount = 0
        for step in 0..<200_000 {
            time += Int.random(in: 0...2, using: &random)
            // A few busy endpoints get most of the traffic
            let index = Int.random(in: 0..<4, using: &random) == 0 ? Int.random(in: 0..<500, using: &random) : Int.random(in: 0..<5, using: &random)
            let got = limiter.allow(endpoints[index], at: time)
            if got != model.allow(endpoints[index], at: time), firstMismatch == nil { firstMismatch = step }
            if got { allowedCount += 1 }
        }
        #expect(firstMismatch == nil)
        #expect(allowedCount > 0 && allowedCount < 200_000)
    }

    @Test("A huge limit and a tiny window")
    func extremes() {
        let generous = EndpointRateLimiter.Limiter(limit: 1_000, window: 1)
        let allowed = (0..<5_000).filter { generous.allow("/ping", at: $0) }.count
        #expect(allowed == 5_000, "a window of 1 ms holds only one request at a time")
        let strict = EndpointRateLimiter.Limiter(limit: 1, window: 1_000_000_000)
        #expect(strict.allow("/ping", at: 0))
        #expect(!strict.allow("/ping", at: 999_999_999))
        #expect(strict.retryAfter("/ping", at: 999_999_999) == 1)
        #expect(strict.allow("/ping", at: 1_000_000_000))
    }
}
