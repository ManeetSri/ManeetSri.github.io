// Reference solution: search field debounce. Every change replaces the one waiting search, so there is
// never more than one: store it as an optional (fire time, query). Before anything happens at time t,
// fire the waiting search if its time is ≤ t. Firing applies the two filters (empty query, same as the
// last search that ran) and puts kept searches in a buffer that `advance(to:)` hands back and empties.
// O(1) per change, and O(k) for an advance that returns k searches.

public enum SearchFieldDebounce {
    public struct Search: Equatable, CustomStringConvertible {
        public let time: Int
        public let query: String

        public init(time: Int, query: String) {
            self.time = time
            self.query = query
        }

        public var description: String { "\(time): \(query)" }
    }

    public final class Debouncer {
        public let delay: Int
        private var waiting: Search? = nil        // the search scheduled by the latest change
        private var lastRun: String? = nil        // the query of the last search that actually ran
        private var fired: [Search] = []          // ran since the last advance, oldest first

        public init(delay: Int) {
            precondition(delay > 0, "The quiet period must be positive")
            self.delay = delay
        }

        /// Fires the waiting search if it is due by `time`.
        private func fireIfDue(by time: Int) {
            guard let search = waiting, search.time <= time else { return }
            waiting = nil
            if search.query.isEmpty || search.query == lastRun { return }
            lastRun = search.query
            fired.append(search)
        }

        public func textChanged(to text: String, at time: Int) {
            fireIfDue(by: time)          // a change at exactly the fire time is too late to cancel it
            waiting = Search(time: time + delay, query: text)
        }

        public func advance(to time: Int) -> [Search] {
            fireIfDue(by: time)
            defer { fired.removeAll(keepingCapacity: true) }
            return fired
        }
    }
}
