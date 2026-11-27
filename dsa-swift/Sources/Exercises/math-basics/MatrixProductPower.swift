// Problem: Matrix product and power (M15 · Matrix basics)

public enum MatrixProductPower {
    /// a × b, or nil if a's column count isn't b's row count.
    public static func product(_ a: [[Int]], _ b: [[Int]]) -> [[Int]]? {
        // Write your solution here, then run:
        // swift test --filter MatrixProductPowerTests
        return nil
    }

    /// The size × size identity matrix.
    public static func identity(size: Int) -> [[Int]] {
        return []
    }

    /// m to the power `exponent` (up to 10¹⁸), entries reduced modulo `modulo`. m is square.
    public static func power(_ m: [[Int]], _ exponent: Int, modulo: Int) -> [[Int]] {
        return []
    }
}
