// Problem: Spot-check a matrix product (M67 · Monte Carlo vs Las Vegas)

public enum FreivaldsProductCheck {
    /// Runs up to `trials` Freivalds trials, each with a fresh random 0/1 vector r drawn from
    /// `generator`, and returns the first r with A(Br) ≠ Cr: a proof that A × B ≠ C. Returns nil if
    /// every trial agrees. Each trial is O(n²); never compute A × B.
    public static func findWitness(_ a: [[Int]], _ b: [[Int]], _ c: [[Int]], trials: Int, using generator: inout some RandomNumberGenerator) -> [Int]? {
        // Write your solution here, then run:
        // swift test --filter FreivaldsProductCheckTests
        return []
    }
}
