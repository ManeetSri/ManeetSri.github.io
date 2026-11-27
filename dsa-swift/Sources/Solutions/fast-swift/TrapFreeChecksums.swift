// Reference solution: Checksums that never trap. Wrapping is spelled with &+ and &*, which wrap in every
// build; overflow that's an error is detected with addingReportingOverflow and
// multipliedReportingOverflow, returning nil at the first one. The midpoint adds the shared bits and half
// the differing bits, (a & b) + ((a ^ b) >> 1), which can't overflow. O(n) time, O(1) space.

public enum TrapFreeChecksums {
    public static func fnv1a(_ text: String) -> UInt64 {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in text.utf8 {
            hash = (hash ^ UInt64(byte)) &* 1_099_511_628_211
        }
        return hash
    }

    public static func wrappingSum(_ values: [Int]) -> Int {
        values.reduce(0, &+)
    }

    public static func checkedSum(_ values: [Int]) -> Int? {
        var total = 0
        for value in values {
            let (sum, overflow) = total.addingReportingOverflow(value)
            if overflow { return nil }
            total = sum
        }
        return total
    }

    public static func checkedProduct(_ values: [Int]) -> Int? {
        var product = 1
        for value in values {
            let (next, overflow) = product.multipliedReportingOverflow(by: value)
            if overflow { return nil }
            product = next
        }
        return product
    }

    public static func midpoint(_ a: Int, _ b: Int) -> Int {
        (a & b) + ((a ^ b) >> 1)                  // shared bits fully, differing bits half, rounded down
    }
}
