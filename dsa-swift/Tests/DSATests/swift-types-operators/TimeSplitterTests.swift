import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TimeSplitterTests {
    @Test("Splits into hours, minutes and seconds", arguments: [
        (3725, 1, 2, 5),
        (59, 0, 0, 59),
        (60, 0, 1, 0),
        (3600, 1, 0, 0),
        (3599, 0, 59, 59),
        (86_399, 23, 59, 59),
    ])
    func splits(total: Int, hours: Int, minutes: Int, seconds: Int) {
        let result = TimeSplitter.split(seconds: total)
        #expect(result.hours == hours)
        #expect(result.minutes == minutes)
        #expect(result.seconds == seconds)
    }

    @Test("Zero seconds is zero everything")
    func zero() {
        let result = TimeSplitter.split(seconds: 0)
        #expect(result.hours == 0 && result.minutes == 0 && result.seconds == 0)
    }

    @Test("Hours keep counting past a day")
    func pastADay() {
        let result = TimeSplitter.split(seconds: 90_061)
        #expect(result.hours == 25)
        #expect(result.minutes == 1)
        #expect(result.seconds == 1)
    }

    @Test("Handles a billion seconds")
    func billion() {
        let result = TimeSplitter.split(seconds: 1_000_000_000)
        #expect(result.hours == 277_777)
        #expect(result.minutes == 46)
        #expect(result.seconds == 40)
    }

    @Test("The parts always add back up to the total", arguments: [1, 61, 4_000, 123_456, 999_999])
    func addsBackUp(total: Int) {
        let result = TimeSplitter.split(seconds: total)
        #expect(result.hours * 3600 + result.minutes * 60 + result.seconds == total)
        #expect((0..<60).contains(result.minutes))
        #expect((0..<60).contains(result.seconds))
    }
}
