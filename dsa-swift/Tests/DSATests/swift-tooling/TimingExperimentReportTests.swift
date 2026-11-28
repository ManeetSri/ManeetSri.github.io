import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

// Every test uses made-up durations, so nothing here depends on how fast the machine is.
@Suite struct TimingExperimentReportTests {
    private static func ms(_ values: [Double]) -> [Duration] {
        values.map { .microseconds(Int(($0 * 1_000).rounded())) }
    }

    private static func isClose(_ value: Double, _ expected: Double) -> Bool {
        abs(value - expected) < 1e-9
    }

    @Test("best is the fastest run")
    func best() {
        #expect(TimingExperimentReport.best(of: Self.ms([4.2, 3.9, 5.0, 3.95])) == .microseconds(3_900))
        #expect(TimingExperimentReport.best(of: [.seconds(2)]) == .seconds(2))
        #expect(TimingExperimentReport.best(of: []) == nil)
    }

    @Test("median is the middle run once sorted")
    func median() {
        #expect(TimingExperimentReport.median(of: Self.ms([9, 1, 5])) == .milliseconds(5))
        #expect(TimingExperimentReport.median(of: Self.ms([30, 10, 40, 20, 50])) == .milliseconds(30))
        #expect(TimingExperimentReport.median(of: [.milliseconds(7)]) == .milliseconds(7))
        #expect(TimingExperimentReport.median(of: []) == nil)
    }

    @Test("With an even number of runs, median is the faster middle one")
    func evenMedian() {
        #expect(TimingExperimentReport.median(of: Self.ms([8, 2, 6, 4])) == .milliseconds(4))
        #expect(TimingExperimentReport.median(of: Self.ms([3, 1])) == .milliseconds(1))
    }

    @Test("milliseconds converts a Duration to a Double", arguments: [
        (Duration.milliseconds(1_500), 1_500.0),
        (Duration.seconds(2), 2_000.0),
        (Duration.microseconds(250), 0.25),
        (Duration.zero, 0.0),
    ])
    func milliseconds(duration: Duration, expected: Double) {
        #expect(Self.isClose(TimingExperimentReport.milliseconds(duration), expected))
    }

    @Test("ratios divide each time by the one before")
    func ratios() {
        let ratios = TimingExperimentReport.ratios(Self.ms([2, 4, 16, 8]))
        #expect(ratios.count == 3)
        #expect(zip(ratios, [2.0, 4.0, 0.5]).allSatisfy { Self.isClose($0, $1) })
        #expect(TimingExperimentReport.ratios(Self.ms([5])) == [])
        #expect(TimingExperimentReport.ratios([]) == [])
    }

    @Test("Doubling experiments", arguments: [
        ([5.0, 5.2, 4.9, 5.1], "constant"),
        ([1.0, 2.0, 4.0, 8.0], "linear"),
        ([3.0, 6.6, 13.0], "linear"),
        ([1.0, 4.0, 16.0], "quadratic"),
        ([0.22, 0.79, 3.13, 13.94], "quadratic"),
        ([1.0, 8.0, 64.0], "cubic"),
    ])
    func growth(times: [Double], expected: String) {
        #expect(TimingExperimentReport.growth(of: Self.ms(times)) == expected)
    }

    @Test("The average ratio decides, at the boundaries too", arguments: [
        ([1.0, 1.49], "constant"),
        ([1.0, 1.5], "linear"),
        ([1.0, 3.0], "quadratic"),
        ([1.0, 6.0], "cubic"),
        ([1.0, 1.0, 4.0], "linear"),
    ])
    func boundaries(times: [Double], expected: String) {
        #expect(TimingExperimentReport.growth(of: Self.ms(times)) == expected)
    }

    @Test("Fewer than two times can't show growth")
    func tooFew() {
        #expect(TimingExperimentReport.growth(of: Self.ms([3])) == nil)
        #expect(TimingExperimentReport.growth(of: []) == nil)
    }
}
