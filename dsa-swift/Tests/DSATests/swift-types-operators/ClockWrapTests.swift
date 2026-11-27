import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ClockWrapTests {
    @Test("Moving forward without passing midnight", arguments: [
        (9, 3, 12),
        (0, 0, 0),
        (13, 10, 23),
    ])
    func forward(start: Int, hours: Int, expected: Int) {
        #expect(ClockWrap.hour(from: start, adding: hours) == expected)
    }

    @Test("Wrapping past midnight", arguments: [
        (22, 5, 3),
        (23, 1, 0),
        (9, 24, 9),
        (6, 50, 8),
        (0, 1_000_000_000, 16),
    ])
    func wrapsForward(start: Int, hours: Int, expected: Int) {
        #expect(ClockWrap.hour(from: start, adding: hours) == expected)
    }

    @Test("Going back in time", arguments: [
        (10, -4, 6),
        (3, -5, 22),
        (0, -1, 23),
        (0, -24, 0),
        (5, -100, 1),
        (23, -1_000_000_000, 7),
    ])
    func backwards(start: Int, hours: Int, expected: Int) {
        #expect(ClockWrap.hour(from: start, adding: hours) == expected)
    }

    @Test("Always lands on a real hour", arguments: [-49, -25, -23, -1, 0, 1, 23, 25, 49])
    func alwaysInRange(hours: Int) {
        #expect((0...23).contains(ClockWrap.hour(from: 12, adding: hours)))
    }
}
