// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Difference array: many range additions, then one pass to read the result
func applyBookings(_ count: Int, _ bookings: [(from: Int, to: Int, seats: Int)]) -> [Int] {
    var difference = Array(repeating: 0, count: count + 1)   // one extra slot for to + 1
    for booking in bookings {
        difference[booking.from] += booking.seats            // starts here
        difference[booking.to + 1] -= booking.seats          // stops after `to`
    }
    var result: [Int] = []
    var running = 0
    for i in 0..<count {
        running += difference[i]
        result.append(running)
    }
    return result
}

print(applyBookings(6, [(0, 2, 10), (1, 4, 5), (4, 5, 3)]))
