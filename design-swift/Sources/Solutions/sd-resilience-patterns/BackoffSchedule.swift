// Reference solution: Backoff schedule. The exponential part is base × factorⁿ, capped; jitter then
// draws from the generator it's given, so a seeded generator makes the whole schedule repeatable.
import Foundation

public enum BackoffSchedule {
    public enum Jitter: Sendable {
        case none
        case full
        case equal
    }

    public static func delays<G: RandomNumberGenerator>(retries: Int, base: Double, factor: Double = 2, cap: Double, jitter: Jitter, using generator: inout G) -> [Double] {
        (0..<max(0, retries)).map { attempt in
            let exponential = min(cap, base * pow(factor, Double(attempt)))
            switch jitter {
            case .none:
                return exponential
            case .full:
                return Double.random(in: 0...exponential, using: &generator)
            case .equal:
                return exponential / 2 + Double.random(in: 0...(exponential / 2), using: &generator)
            }
        }
    }
}
