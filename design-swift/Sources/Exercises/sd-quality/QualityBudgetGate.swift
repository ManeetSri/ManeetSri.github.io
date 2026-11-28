// Kata: Performance budget gate (D01 · Measuring quality: ISO 25010 and fitness functions)
import Foundation

public enum QualityBudgetGate {
    /// How a list of samples becomes one number to compare against a budget
    public enum Statistic: Sendable, Equatable {
        case mean
        case maximum
        /// Nearest-rank percentile, `p` from 0 to 100: sort the samples and take the one at rank
        /// ⌈p × n ÷ 100⌉, counting from 1 (and never below rank 1)
        case percentile(Double)
    }

    public enum Direction: Sendable, Equatable {
        /// Launch time, memory, app size: a measurement above the limit breaches it
        case lowerIsBetter
        /// Crash-free sessions, frame rate: a measurement below the limit breaches it
        case higherIsBetter
    }

    public struct Budget: Sendable, Equatable {
        /// Names this budget in outcomes and in the baseline, such as "cold-launch-p90"
        public let id: String
        /// Which samples to read, such as "coldLaunchMs"
        public let metric: String
        public let statistic: Statistic
        /// The worst acceptable value. A measurement exactly at the limit passes.
        public let limit: Double
        public let direction: Direction
        /// Fails a measurement that's worse than its baseline by more than this fraction (0.1 = 10%),
        /// even when it's inside the limit. `nil` turns regression checks off for this budget.
        public let maxRegression: Double?

        public init(id: String, metric: String, statistic: Statistic, limit: Double, direction: Direction = .lowerIsBetter, maxRegression: Double? = nil) {
            self.id = id
            self.metric = metric
            self.statistic = statistic
            self.limit = limit
            self.direction = direction
            self.maxRegression = maxRegression
        }
    }

    public enum Verdict: Sendable, Equatable {
        case pass
        /// Worse than the limit
        case breached
        /// Inside the limit, but worse than the baseline by more than `maxRegression`
        case regressed
        /// No samples for the metric. A check that can't measure must not pass.
        case noData
    }

    public struct Outcome: Sendable, Equatable {
        public let budgetID: String
        /// The statistic's value, or `nil` when there was no data
        public let measured: Double?
        public let verdict: Verdict

        public init(budgetID: String, measured: Double?, verdict: Verdict) {
            self.budgetID = budgetID
            self.measured = measured
            self.verdict = verdict
        }
    }

    /// The statistic for these samples, or `nil` when there are none
    public static func value(of statistic: Statistic, in samples: [Double]) -> Double? {
        // Write your solution here, then run:
        // swift test --filter QualityBudgetGateTests
        return nil
    }

    /// One outcome per budget, in the budgets' order. A breach wins over a regression; the baseline is
    /// keyed by budget id, and a budget without a baseline entry isn't checked for regression.
    public static func evaluate(_ budgets: [Budget], samples: [String: [Double]], baseline: [String: Double] = [:]) -> [Outcome] {
        return []
    }

    /// The baseline to keep for next time: every passing outcome moves its budget's entry to the better
    /// of the old value and the new measurement (lower or higher, by the budget's direction), and adds
    /// one if there was none. Anything that didn't pass leaves its entry alone; other entries are kept.
    public static func ratchet(_ baseline: [String: Double], budgets: [Budget], outcomes: [Outcome]) -> [String: Double] {
        return baseline
    }
}
