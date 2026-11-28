// Reference solution: Volunteer roster. A difference array: each pledge adds at its first day and
// subtracts the day after its last, then one running sum turns the changes into totals.
// O(days + pledges) time, O(days) space.

public enum VolunteerRoster {
    public static func volunteersPerDay(days: Int, pledges: [(first: Int, last: Int, people: Int)]) -> [Int] {
        // Day d lives at index d - 1. One spare slot so `last` can be the final day.
        var change = Array(repeating: 0, count: days + 1)
        for pledge in pledges {
            change[pledge.first - 1] += pledge.people
            change[pledge.last] -= pledge.people      // index of the day after `last`
        }
        var totals: [Int] = []
        totals.reserveCapacity(days)
        var running = 0
        for index in 0..<days {
            running += change[index]
            totals.append(running)
        }
        return totals
    }
}
