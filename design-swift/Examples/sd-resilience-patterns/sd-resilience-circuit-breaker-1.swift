// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-circuit-breaker.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// A circuit breaker as a plain state machine, with time passed in so the run is repeatable
struct CircuitBreaker {
    enum State: Equatable {
        case closed(failures: Int)
        case open(until: Int)
        case halfOpen
    }

    let threshold: Int
    let cooldown: Int
    private(set) var state = State.closed(failures: 0)

    init(threshold: Int, cooldown: Int) {
        self.threshold = threshold
        self.cooldown = cooldown
    }

    /// Whether a call at `now` may go to the server. After the cooldown, one call goes through as a trial.
    mutating func allows(at now: Int) -> Bool {
        guard case .open(let until) = state else { return true }
        guard now >= until else { return false }
        state = .halfOpen
        return true
    }

    mutating func record(success: Bool, at now: Int) {
        switch (state, success) {
        case (_, true):
            state = .closed(failures: 0)
        case (.closed(let failures), false) where failures + 1 < threshold:
            state = .closed(failures: failures + 1)
        case (_, false):
            state = .open(until: now + cooldown)
        }
    }
}

// The recommendations service is down until 20 s; the app asks every 3 s
var breaker = CircuitBreaker(threshold: 3, cooldown: 10)
var reachedServer = 0
for now in stride(from: 0, through: 30, by: 3) {
    var isTrial = false
    if case .open = breaker.state { isTrial = true }
    guard breaker.allows(at: now) else {
        print("\(now) s: turned away")
        continue
    }
    reachedServer += 1
    let healthy = now >= 20
    breaker.record(success: healthy, at: now)
    print("\(now) s: \(isTrial ? "trial" : "sent"), \(healthy ? "succeeded" : "failed") -> \(breaker.state)")
}
print("Calls that reached the server: \(reachedServer) of 11")
