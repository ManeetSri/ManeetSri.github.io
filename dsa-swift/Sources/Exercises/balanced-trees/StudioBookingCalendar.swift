// Problem: Studio booking calendar (M38 · Build an ordered set and map in Swift)

import DSAKit   // DSAKit's SortedMap is here if you want it

public enum StudioBookingCalendar {
    /// The bookings for one recording studio. A booking covers the half-open time range
    /// `start..<end`, so one that ends at 10 doesn't clash with one that starts at 10.
    public struct Schedule {
        // Write your solution here, then run:
        // swift test --filter StudioBookingCalendarTests
        // Add whatever private storage you need.

        public init() {}

        /// Accepts the booking `start..<end` and returns true if it overlaps no booking accepted so far;
        /// otherwise returns false and changes nothing. `start < end` always.
        public mutating func book(start: Int, end: Int) -> Bool {
            return false
        }

        /// How many bookings have been accepted.
        public var count: Int {
            return 0
        }
    }
}
