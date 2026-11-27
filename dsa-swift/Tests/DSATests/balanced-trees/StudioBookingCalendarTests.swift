import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct StudioBookingCalendarTests {
    typealias Schedule = StudioBookingCalendar.Schedule

    /// Books each range in order and returns the answers.
    private func answers(_ requests: [(Int, Int)]) -> [Bool] {
        var schedule = Schedule()
        return requests.map { schedule.book(start: $0.0, end: $0.1) }
    }

    @Test("The statement's example")
    func example() {
        #expect(answers([(10, 20), (15, 25), (20, 30), (5, 10), (8, 12), (30, 31)])
            == [true, false, true, true, false, true])
    }

    @Test("Touching ends are fine; any overlap isn't")
    func edges() {
        #expect(answers([(10, 20), (20, 30), (0, 10)]) == [true, true, true])
        #expect(answers([(10, 20), (10, 20)]) == [true, false])          // the same range
        #expect(answers([(10, 20), (12, 18)]) == [true, false])          // inside
        #expect(answers([(10, 20), (5, 25)]) == [true, false])           // around
        #expect(answers([(10, 20), (19, 21)]) == [true, false])          // over the end
        #expect(answers([(10, 20), (9, 11)]) == [true, false])           // over the start
        #expect(answers([(10, 20), (10, 11)]) == [true, false])          // same start
        #expect(answers([(10, 20), (19, 20)]) == [true, false])          // same end
    }

    @Test("A gap between two bookings can be filled exactly, but not overfilled")
    func gaps() {
        var schedule = Schedule()
        #expect(schedule.book(start: 0, end: 10) == true)
        #expect(schedule.book(start: 20, end: 30) == true)
        #expect(schedule.book(start: 9, end: 20) == false)
        #expect(schedule.book(start: 10, end: 21) == false)
        #expect(schedule.book(start: 10, end: 20) == true)
        #expect(schedule.book(start: 15, end: 16) == false)
        #expect(schedule.count == 3)
    }

    @Test("Negative times and one-unit bookings")
    func negatives() {
        #expect(answers([(-5, -1), (-1, 0), (-3, -2), (-10, -5), (-6, -4)]) == [true, true, false, true, false])
    }

    @Test("Rejected bookings don't count")
    func counting() {
        var schedule = Schedule()
        _ = schedule.book(start: 1, end: 5)
        _ = schedule.book(start: 2, end: 3)
        _ = schedule.book(start: 5, end: 6)
        #expect(schedule.count == 2)
    }

    @Test("Matches a brute-force check on small random requests")
    func againstBruteForce() {
        var state: UInt64 = 7
        func next(_ limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
        var schedule = Schedule()
        var accepted: [(Int, Int)] = []
        var wrong = 0
        for _ in 0..<3_000 {
            let start = next(5_000)
            let end = start + 1 + next(20)
            let expected = !accepted.contains { $0.0 < end && start < $0.1 }
            if expected { accepted.append((start, end)) }
            if schedule.book(start: start, end: end) != expected { wrong += 1 }
        }
        #expect(wrong == 0)
        #expect(schedule.count == accepted.count)
    }

    @Test("150,000 requests in a scrambled order")
    func large() {
        let n = 50_000
        var schedule = Schedule()
        var wrong = 0
        // Slot i is i * 2 ..< i * 2 + 1. Visiting i * 7_919 % n reaches every slot once in a scrambled order.
        for k in 0..<n {
            let i = (k * 7_919) % n
            if !schedule.book(start: i * 2, end: i * 2 + 1) { wrong += 1 }
            if schedule.book(start: i * 2, end: i * 2 + 2) { wrong += 1 }     // clashes with slot i
        }
        // Now every gap between neighbouring slots can be filled
        for i in 0..<(n - 1) where !schedule.book(start: i * 2 + 1, end: i * 2 + 2) {
            wrong += 1
        }
        #expect(wrong == 0)
        #expect(schedule.count == 2 * n - 1)
        #expect(schedule.book(start: 0, end: 2 * n) == false)
    }
}
