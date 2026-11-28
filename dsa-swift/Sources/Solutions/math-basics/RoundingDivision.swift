// Reference solution: Rounding division for every Int. Correct Swift's truncated quotient by one when
// the division isn't exact and the signs call for it; add b to a negative remainder only. O(1).

public enum RoundingDivision {
    public static func floorQuotient(_ a: Int, _ b: Int) -> Int {
        let q = a / b
        if a % b != 0 && (a < 0) != (b < 0) {   // negative answer: truncation rounded up
            return q - 1
        }
        return q
    }

    public static func ceilingQuotient(_ a: Int, _ b: Int) -> Int {
        let q = a / b
        if a % b != 0 && (a < 0) == (b < 0) {   // positive answer: truncation rounded down
            return q + 1
        }
        return q
    }

    public static func offset(_ a: Int, within b: Int) -> Int {
        let r = a % b                            // between -b and b, exclusive
        return r < 0 ? r + b : r                 // never adds b to a positive value
    }
}
