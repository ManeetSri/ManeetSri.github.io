// Problem: Strassen with a cutoff (M49 · Strassen's algorithm)

public enum StrassenSevenProducts {
    public typealias Matrix = [[Int]]

    /// `a` and `b` are n × n with n a power of two. Multiplies them with Strassen's algorithm: at size
    /// `cutoff` or below, the standard method (n³ multiplications); above it, seven recursive products
    /// of half-size blocks, combined with additions and subtractions. Returns the product and the
    /// total number of scalar multiplications made (additions and subtractions don't count).
    public static func multiply(_ a: Matrix, _ b: Matrix, cutoff: Int) -> (product: Matrix, multiplications: Int) {
        // Write your solution here, then run:
        // swift test --filter StrassenSevenProductsTests
        return ([], 0)
    }
}
