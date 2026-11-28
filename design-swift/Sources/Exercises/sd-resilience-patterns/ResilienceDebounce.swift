// Kata: Debounce an async stream (D14 · Debounce, throttle and coalesce)

public enum ResilienceDebounce {
    /// A stream of `upstream`'s elements, debounced: each element waits until `quiet` has passed with no
    /// newer one, and is dropped if a newer one arrives first. When `upstream` finishes, the element still
    /// waiting (if any) comes out at once and the stream finishes. When the consumer stops listening,
    /// stop reading `upstream` and cancel any timer.
    public static func debounce<Element: Sendable>(_ upstream: AsyncStream<Element>, for quiet: Duration, clock: some Clock<Duration>) -> AsyncStream<Element> {
        // Write your solution here, then run:
        // swift test --filter ResilienceDebounceTests
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}
