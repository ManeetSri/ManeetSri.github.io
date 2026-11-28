// Problem: Ranked search suggestions (M72 · Autocomplete system)

public enum RankedSearchSuggestions {
    /// A search box's suggestion engine. It knows how often each phrase has been searched, suggests
    /// the most popular phrases that start with what has been typed so far, and learns from each
    /// submitted search.
    public final class Engine {
        // Write your solution here, then run:
        // swift test --filter RankedSearchSuggestionsTests
        // Add whatever private storage you need.

        /// Creates an engine that knows each phrase in `history` with its count, and suggests at
        /// most `limit` phrases (at least 1).
        public init(history: [String: Int], limit: Int = 3) {
        }

        /// What has been typed since the last submit or clear.
        public var query: String {
            return ""
        }

        /// Adds `character` to the query and returns the suggestions for the new query.
        public func type(_ character: Character) -> [String] {
            return []
        }

        /// Records one more search for the query (if it isn't empty) and starts a new, empty query.
        public func submit() {
        }

        /// Starts a new, empty query without recording anything.
        public func clear() {
        }

        /// The suggestions for `prefix`: the phrases that start with it, highest count first, equal
        /// counts in alphabetical order, at most `limit` of them.
        public func suggestions(for prefix: String) -> [String] {
            return []
        }
    }
}
