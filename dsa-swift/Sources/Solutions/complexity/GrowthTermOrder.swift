// Reference solution: Order the growth terms. The coefficient never matters; compare the base, then the
// power of n, then the power of log n. O(1) per comparison, O(t log t) to sort t terms.

public enum GrowthTermOrder {
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

    public enum Relation: Equatable {
        case littleO, theta, littleOmega
    }

    // Tuples compare left to right: an exponential beats any power, a power beats any log power
    static func growth(_ term: Term) -> (Int, Int, Int) {
        (term.base, term.power, term.logPower)
    }

    public static func relation(_ f: Term, _ g: Term) -> Relation {
        if growth(f) < growth(g) { return .littleO }
        if growth(f) > growth(g) { return .littleOmega }
        return .theta
    }

    public static func ladder(_ terms: [Term]) -> [Term] {
        // The index breaks ties, so equal-growth terms keep their order whatever the sort does
        let ordered = terms.enumerated().sorted { first, second in
            let (a, b) = (first.element, second.element)
            return (a.base, a.power, a.logPower, first.offset) < (b.base, b.power, b.logPower, second.offset)
        }
        return ordered.map { $0.element }
    }
}
