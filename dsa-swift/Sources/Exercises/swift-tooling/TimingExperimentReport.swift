// Problem: Reading a timing experiment (M12 · Timing code with ContinuousClock)

public enum TimingExperimentReport {
    /// The fastest of `runs`, or nil if there are none.
    public static func best(of runs: [Duration]) -> Duration? {
        // Write your solution here, then run:
        // swift test --filter TimingExperimentReportTests
        return nil
    }

    /// The middle run once sorted from fastest to slowest. With an even number of runs, the faster of
    /// the two middle ones. Nil if there are none.
    public static func median(of runs: [Duration]) -> Duration? {
        return nil
    }

    /// `duration` in milliseconds, as a Double.
    public static func milliseconds(_ duration: Duration) -> Double {
        return 0
    }

    /// For times measured at sizes n, 2n, 4n, ...: each time divided by the one before it.
    public static func ratios(_ times: [Duration]) -> [Double] {
        return []
    }

    /// How the time grows as the size doubles, judged by the average of the ratios: below 1.5 is
    /// "constant", below 3 is "linear", below 6 is "quadratic", and anything more is "cubic".
    /// Nil with fewer than two times.
    public static func growth(of times: [Duration]) -> String? {
        return nil
    }
}
