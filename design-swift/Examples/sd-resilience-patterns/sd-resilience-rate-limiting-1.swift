// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-rate-limiting.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// A token bucket that never refuses: it tells each request how long to wait instead
struct TokenBucket {
    let capacity: Double
    let refillPerSecond: Double
    private var tokens: Double
    private var updatedAt = 0.0

    init(capacity: Double, refillPerSecond: Double) {
        self.capacity = capacity
        self.refillPerSecond = refillPerSecond
        tokens = capacity
    }

    /// Takes a token for a request made at `now` (in seconds), and returns how long it must wait to be sent
    mutating func reserve(at now: Double) -> Double {
        tokens = min(capacity, tokens + (now - updatedAt) * refillPerSecond)
        updatedAt = now
        tokens -= 1
        // Below zero is a queue of reservations: each one waits for the refill to reach it
        return tokens >= 0 ? 0 : -tokens / refillPerSecond
    }
}

var bucket = TokenBucket(capacity: 5, refillPerSecond: 2)
// The user opens a screen that fires 8 requests at once
let burst = (1...8).map { _ in bucket.reserve(at: 0) }
print("Burst of 8 at 0 s, waits:", burst)
// Three seconds later the bucket has refilled enough to send at once again
print("One more at 3 s, wait:", bucket.reserve(at: 3))
