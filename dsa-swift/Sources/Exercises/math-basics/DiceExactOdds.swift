// Problem: Exact dice odds (M15 · Probability and expected value)

public enum DiceExactOdds {
    /// numerator / denominator. Answers must be in lowest terms with a positive denominator; zero is 0/1.
    public struct Fraction: Equatable, CustomStringConvertible {
        public var numerator: Int
        public var denominator: Int

        public init(numerator: Int, denominator: Int) {
            self.numerator = numerator
            self.denominator = denominator
        }

        public var description: String { "\(numerator)/\(denominator)" }
    }

    /// The probability that `dice` fair dice with faces 1...faces add up to `target`.
    public static func sumChance(of target: Int, dice: Int, faces: Int) -> Fraction {
        // Write your solution here, then run:
        // swift test --filter DiceExactOddsTests
        return Fraction(numerator: 0, denominator: 0)
    }

    /// The expected value of the largest face showing.
    public static func expectedHighest(dice: Int, faces: Int) -> Fraction {
        return Fraction(numerator: 0, denominator: 0)
    }
}
