// Problem: Checksums that never trap (M68 · Debug, release and -Ounchecked)

public enum TrapFreeChecksums {
    /// The 64-bit FNV-1a hash of the text's UTF-8 bytes, with the multiplication wrapping around.
    public static func fnv1a(_ text: String) -> UInt64 {
        // Write your solution here, then run:
        // swift test --filter TrapFreeChecksumsTests
        // A plain + or * that overflows crashes the whole test run: never let one overflow.
        return 0
    }

    /// The sum of `values`, wrapping around on overflow.
    public static func wrappingSum(_ values: [Int]) -> Int {
        return -1
    }

    /// The sum of `values` added left to right, or nil if any running total overflows.
    public static func checkedSum(_ values: [Int]) -> Int? {
        return -1
    }

    /// The product of `values` multiplied left to right, or nil if any running product overflows.
    public static func checkedProduct(_ values: [Int]) -> Int? {
        return -1
    }

    /// The average of a and b rounded down, for any two Ints.
    public static func midpoint(_ a: Int, _ b: Int) -> Int {
        return 0
    }
}
