// Problem: A tally built from literals (M10 · ExpressibleByArrayLiteral)

public enum TallyLiterals {
    /// Counts how many times each element appears.
    public struct Tally<Element: Hashable>: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
        // Write your solution here, then run:
        // swift test --filter TallyLiteralsTests
        // Add whatever private storage you need.

        /// An empty tally.
        public init() {}

        /// `["tea", "coffee", "tea"]`: counts each element once per appearance.
        public init(arrayLiteral elements: Element...) {
        }

        /// `["tea": 2, "coffee": 1]`: adds each count. Zero or negative counts are ignored, and a
        /// repeated key adds up.
        public init(dictionaryLiteral pairs: (Element, Int)...) {
        }

        /// Adds `times` to the count of `element`. Zero or negative `times` are ignored.
        public mutating func add(_ element: Element, times: Int = 1) {
        }

        /// How many times `element` has been counted (0 if never).
        public func count(of element: Element) -> Int {
            return 0
        }

        /// The sum of every count.
        public var total: Int {
            return 0
        }

        /// How many different elements have been counted.
        public var distinctCount: Int {
            return 0
        }

        /// The different elements, in the order each was first counted.
        public var elements: [Element] {
            return []
        }

        /// The element with the highest count; on a tie, the one counted first. Nil when empty.
        public var mostCommon: Element? {
            return nil
        }

        /// A new tally holding the counts of both. Elements keep the order they first arrived,
        /// this tally's first.
        public func merged(with other: Tally) -> Tally {
            return Tally()
        }
    }
}
