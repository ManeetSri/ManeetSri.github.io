import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NamedTimeUnitsTests {
    @Test("Converts one of each unit on its own")
    func eachUnit() {
        #expect(NamedTimeUnits.totalSeconds(weeks: 0, days: 0, hours: 0, minutes: 1) == 60)
        #expect(NamedTimeUnits.totalSeconds(weeks: 0, days: 0, hours: 1, minutes: 0) == 3_600)
        #expect(NamedTimeUnits.totalSeconds(weeks: 0, days: 1, hours: 0, minutes: 0) == 86_400)
        #expect(NamedTimeUnits.totalSeconds(weeks: 1, days: 0, hours: 0, minutes: 0) == 604_800)
    }

    @Test("Adds the parts together", arguments: [
        (1, 2, 3, 4, 788_640),
        (0, 0, 1, 30, 5_400),
        (0, 1, 12, 0, 129_600),
        (2, 0, 0, 15, 1_210_500),
    ])
    func addsParts(weeks: Int, days: Int, hours: Int, minutes: Int, expected: Int) {
        #expect(NamedTimeUnits.totalSeconds(weeks: weeks, days: days, hours: hours, minutes: minutes) == expected)
    }

    @Test("Allows parts beyond a full unit")
    func overflowingParts() {
        // 7 days is a week, 24 hours is a day and 60 minutes is an hour.
        #expect(NamedTimeUnits.totalSeconds(weeks: 0, days: 7, hours: 0, minutes: 0) == 604_800)
        #expect(NamedTimeUnits.totalSeconds(weeks: 0, days: 0, hours: 24, minutes: 0) == 86_400)
        #expect(NamedTimeUnits.totalSeconds(weeks: 0, days: 0, hours: 0, minutes: 60) == 3_600)
    }

    @Test("No time at all is zero seconds")
    func zero() {
        #expect(NamedTimeUnits.totalSeconds(weeks: 0, days: 0, hours: 0, minutes: 0) == 0)
    }

    @Test("Handles the largest durations allowed")
    func largest() {
        // 10,000 of each: 6,048,000,000 + 864,000,000 + 36,000,000 + 600,000
        #expect(NamedTimeUnits.totalSeconds(weeks: 10_000, days: 10_000, hours: 10_000, minutes: 10_000) == 6_948_600_000)
    }
}
