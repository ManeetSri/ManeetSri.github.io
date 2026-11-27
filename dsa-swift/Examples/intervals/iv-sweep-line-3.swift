// Generated from src/dsa/content/lessons/intervals/iv-sweep-line.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct BookingCalendar {
    private var bookings: [[Int]] = []      // accepted, half-open [start, end)

    mutating func book(_ start: Int, _ end: Int) -> Bool {
        if bookings.contains(where: { start < $0[1] && $0[0] < end }) {
            return false                    // it overlaps an accepted booking
        }
        bookings.append([start, end])
        return true
    }
}

var calendar = BookingCalendar()
print(calendar.book(10, 20))
print(calendar.book(15, 25))
print(calendar.book(20, 30))
print(calendar.book(5, 10))
print(calendar.book(8, 12))
