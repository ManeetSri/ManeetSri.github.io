// Kata: Backoff schedule (D14 · Retry with exponential backoff and jitter)
import Foundation

public enum BackoffSchedule {
    /// How randomness spreads retries out, so many clients that failed together don't retry together
    public enum Jitter: Sendable {
        /// Exactly the exponential delay
        case none
        /// Anywhere from zero up to the exponential delay
        case full
        /// Half the exponential delay, plus up to another half at random
        case equal
    }

    /// The delay in seconds before each of `retries` retries. The first waits `base`, each one after
    /// `factor` times longer than the one before, and none longer than `cap`; then jitter is applied.
    public static func delays<G: RandomNumberGenerator>(retries: Int, base: Double, factor: Double = 2, cap: Double, jitter: Jitter, using generator: inout G) -> [Double] {
        // Write your solution here, then run:
        // swift test --filter BackoffScheduleTests
        return []
    }
}
