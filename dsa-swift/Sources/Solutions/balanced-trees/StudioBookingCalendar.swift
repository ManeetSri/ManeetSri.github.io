// Reference solution: Studio booking calendar. Accepted bookings never overlap, so sorted by start
// they're sorted by end too. A new booking can only clash with its two neighbours: the booking that
// starts at or before it (floor), which clashes if it ends after the new start, and the booking that
// starts at or after it (ceiling), which clashes if it starts before the new end. A SortedMap from
// start to end answers both in O(log n), and inserting is O(log n) too.

import DSAKit

public enum StudioBookingCalendar {
    public struct Schedule {
        private var endsByStart = SortedMap<Int, Int>()

        public init() {}

        public mutating func book(start: Int, end: Int) -> Bool {
            if let before = endsByStart.floor(start), before.value > start {
                return false                                 // the earlier booking runs past our start
            }
            if let after = endsByStart.ceiling(start), after.key < end {
                return false                                 // the later booking starts before our end
            }
            endsByStart[start] = end
            return true
        }

        public var count: Int {
            endsByStart.count
        }
    }
}
