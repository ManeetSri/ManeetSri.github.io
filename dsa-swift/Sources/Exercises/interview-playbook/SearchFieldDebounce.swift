// Problem: Search field debounce (M71 · iOS-flavoured DSA questions)

public enum SearchFieldDebounce {
    /// A search request: when it ran, and the query it sent.
    public struct Search: Equatable, CustomStringConvertible {
        public let time: Int
        public let query: String

        public init(time: Int, query: String) {
            self.time = time
            self.query = query
        }

        public var description: String { "\(time): \(query)" }
    }

    /// Simulates a debounced search field. Each change at time `t` schedules a search for `t + delay`
    /// with the text at that moment, cancelling any search still waiting. A waiting search runs at its
    /// time unless a change comes *before* then; a change at exactly that time is too late to cancel it.
    /// A search doesn't run if its query is empty or is the same as the last search that did run.
    /// Times never decrease from one call to the next.
    public final class Debouncer {
        public let delay: Int

        public init(delay: Int) {
            self.delay = delay
        }

        /// The field's text changed to `text` at `time`.
        public func textChanged(to text: String, at time: Int) {
            // Write your solution here, then run:
            // swift test --filter SearchFieldDebounceTests
        }

        /// Moves the clock to `time` and returns every search that ran since the previous call to
        /// `advance`, oldest first, including any that ran at exactly `time`.
        public func advance(to time: Int) -> [Search] {
            return []
        }
    }
}
