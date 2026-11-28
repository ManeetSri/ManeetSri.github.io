import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LeapYearRuleTests {
    @Test("Years divisible by 4 are leap years", arguments: [2024, 1996, 2012, 4, 8])
    func divisibleByFour(year: Int) {
        #expect(LeapYearRule.isLeapYear(year))
    }

    @Test("Other years are not", arguments: [2023, 2019, 2001, 1, 7, 9999])
    func notDivisibleByFour(year: Int) {
        #expect(!LeapYearRule.isLeapYear(year))
    }

    @Test("Century years are not leap years", arguments: [1900, 1800, 2100, 100, 1700])
    func centuries(year: Int) {
        #expect(!LeapYearRule.isLeapYear(year))
    }

    @Test("Unless they are divisible by 400", arguments: [2000, 1600, 2400, 400, 8000])
    func fourHundreds(year: Int) {
        #expect(LeapYearRule.isLeapYear(year))
    }
}
