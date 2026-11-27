// Reference solution: Solve a linear congruence. Reduce a and b into 0..<m first. With g = gcd(a, m),
// a solution exists exactly when g divides b. Dividing everything by g leaves (a/g)·x ≡ b/g (mod m/g),
// where a/g is invertible, and the same extended Euclid call that found g gives that inverse. One
// 128-bit multiplication then gives x, already the smallest answer, because every solution is x plus a
// multiple of m/g. O(log m) time, O(1) space.

public enum LinearCongruenceSolver {
    public static func smallestSolution(a: Int, b: Int, modulus m: Int) -> Int? {
        let a = ((a % m) + m) % m
        let b = ((b % m) + m) % m
        let (g, x, _) = extendedGCD(a, m)              // a·x + m·y = g
        guard b % g == 0 else { return nil }
        let step = m / g                                // solutions repeat every m / g
        let inverse = ((x % step) + step) % step        // (a / g)·x ≡ 1 (mod m / g)
        return mulMod(b / g, inverse, step)             // both factors are below step, so this is exact
    }

    /// Iterative extended Euclid: returns (g, x, y) with a·x + b·y = g = gcd(a, b).
    private static func extendedGCD(_ a: Int, _ b: Int) -> (g: Int, x: Int, y: Int) {
        var (oldR, r) = (a, b)
        var (oldS, s) = (1, 0)
        var (oldT, t) = (0, 1)
        while r != 0 {
            let q = oldR / r
            (oldR, r) = (r, oldR - q * r)
            (oldS, s) = (s, oldS - q * s)
            (oldT, t) = (t, oldT - q * t)
        }
        return (oldR, oldS, oldT)
    }

    /// a·b mod m for 0 ≤ a, b < m, through the full 128-bit product, so nothing overflows.
    private static func mulMod(_ a: Int, _ b: Int, _ m: Int) -> Int {
        m.dividingFullWidth(a.multipliedFullWidth(by: b)).remainder
    }
}
