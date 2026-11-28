// Reference solution: Rooms needed. The answer is the peak number of meetings running at once. Sort
// the starts and the ends separately, and walk the starts in order; before counting each start,
// release every meeting that has ended by then (half-open, so an end at the same time comes first).
// O(n log n) time for the sorts, O(n) space.

public enum RoomsNeeded {
    public static func minimumRooms(_ meetings: [[Int]]) -> Int {
        let starts = meetings.map { $0[0] }.sorted()
        let ends = meetings.map { $0[1] }.sorted()
        var inUse = 0
        var most = 0
        var e = 0
        for start in starts {
            while e < ends.count && ends[e] <= start {
                inUse -= 1
                e += 1
            }
            inUse += 1
            most = max(most, inUse)
        }
        return most
    }
}
