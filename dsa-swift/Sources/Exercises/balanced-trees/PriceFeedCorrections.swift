// Problem: Price feed with corrections (M38 · Build an ordered set and map in Swift)

import DSAKit   // DSAKit's SortedMap is here if you want it

public enum PriceFeedCorrections {
    /// Prices for one stock, each stamped with a time. Records can arrive out of order, and a record
    /// for a time that already has a price is a correction: it replaces the old price.
    public struct Feed {
        // Write your solution here, then run:
        // swift test --filter PriceFeedCorrectionsTests
        // Add whatever private storage you need.

        public init() {}

        /// Records `price` at `time`, replacing any price already recorded at that time. O(log n).
        public mutating func record(time: Int, price: Int) {
        }

        /// The price at the latest time recorded so far, or nil if nothing has been recorded. O(1) or
        /// O(log n).
        public var latest: Int? {
            return nil
        }

        /// The highest current price over all times, or nil if nothing has been recorded. A price that
        /// was corrected away no longer counts. O(log n).
        public var highest: Int? {
            return nil
        }

        /// The lowest current price over all times, or nil if nothing has been recorded. O(log n).
        public var lowest: Int? {
            return nil
        }
    }
}
