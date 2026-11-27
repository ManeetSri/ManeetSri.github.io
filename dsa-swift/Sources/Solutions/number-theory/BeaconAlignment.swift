// Reference solution: When all the beacons flash. Beacon i flashes at the times t ≡ offset (mod period),
// so the answer is the smallest solution of a system of congruences: the Chinese remainder theorem,
// without assuming the periods are coprime. Merge the congruences one at a time. To combine
// t ≡ a (mod m) with t ≡ b (mod n), write t = a + m·k; then m·k ≡ b − a (mod n), which is solvable
// exactly when g = gcd(m, n) divides b − a, and then k = ((b − a)/g)·inv(m/g) mod n/g. Extended Euclid
// gives the inverse, and the product needs 128 bits because both factors can be near 10¹⁸. The merged
// modulus is lcm(m, n), and a + m·k is below it, so the running answer is always the smallest one.
// O(beacons · log P) time for periods up to P, O(1) space.

public enum BeaconAlignment {
    public static func firstSharedFlash(offsets: [Int], periods: [Int]) -> Int? {
        var time = 0                                    // t ≡ 0 (mod 1) allows every time
        var cycle = 1
        for (offset, period) in zip(offsets, periods) {
            let (g, p, _) = extendedGCD(cycle, period)  // cycle·p + period·q = g
            let difference = offset - time
            guard difference % g == 0 else { return nil }
            let step = period / g                       // k only matters modulo period / g
            let target = ((difference / g) % step + step) % step
            let inverse = ((p % step) + step) % step    // (cycle / g)·p ≡ 1 (mod period / g)
            let k = mulMod(target, inverse, step)
            time += cycle * k                           // below lcm(cycle, period), so it fits
            cycle = cycle / g * period                  // the new lcm, at most 10¹⁸ by the constraints
        }
        return time
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

    /// a·b mod m for 0 ≤ a, b < m, through the full 128-bit product.
    private static func mulMod(_ a: Int, _ b: Int, _ m: Int) -> Int {
        m.dividingFullWidth(a.multipliedFullWidth(by: b)).remainder
    }
}
