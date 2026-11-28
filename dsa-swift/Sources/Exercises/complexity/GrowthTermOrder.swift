// Problem: Order the growth terms (M14 · little-o and little-ω)

public enum GrowthTermOrder {
    /// coefficient × baseⁿ × n^power × (log n)^logPower. A base of 1 means no exponential part.
    public struct Term: Equatable {
        public var coefficient: Int
        public var base: Int
        public var power: Int
        public var logPower: Int

        public init(coefficient: Int = 1, base: Int = 1, power: Int = 0, logPower: Int = 0) {
            self.coefficient = coefficient
            self.base = base
            self.power = power
            self.logPower = logPower
        }
    }

    /// How f compares with g: strictly slower, the same rate, or strictly faster.
    public enum Relation: Equatable {
        case littleO, theta, littleOmega
    }

    /// `.littleO` if f is o(g), `.theta` if f is Θ(g), `.littleOmega` if f is ω(g).
    public static func relation(_ f: Term, _ g: Term) -> Relation {
        // Write your solution here, then run:
        // swift test --filter GrowthTermOrderTests
        return .theta
    }

    /// The terms from slowest-growing to fastest; terms with the same growth keep their order.
    public static func ladder(_ terms: [Term]) -> [Term] {
        return []
    }
}
