// Reference solution: String to integer, clamped. Walk the bytes with one index: skip spaces, read an
// optional sign, then read digits until anything else appears. Each digit is folded in with
// multipliedReportingOverflow and addingReportingOverflow, and the first overflow returns the clamped
// limit for the sign. The magnitude of Int.min doesn't fit in an Int, but it overflows exactly when
// the answer should be clamped to Int.min, so building the positive magnitude is safe.
// O(n) time, O(n) space for the byte array.

public enum ClampedIntegerParse {
    public static func parse(_ text: String) -> Int {
        let bytes = Array(text.utf8)
        var index = 0
        while index < bytes.count && bytes[index] == UInt8(ascii: " ") {
            index += 1
        }
        var negative = false
        if index < bytes.count && (bytes[index] == UInt8(ascii: "+") || bytes[index] == UInt8(ascii: "-")) {
            negative = bytes[index] == UInt8(ascii: "-")
            index += 1
        }
        var value = 0
        while index < bytes.count && bytes[index] >= UInt8(ascii: "0") && bytes[index] <= UInt8(ascii: "9") {
            let digit = Int(bytes[index] - UInt8(ascii: "0"))
            let shifted = value.multipliedReportingOverflow(by: 10)
            let added = shifted.partialValue.addingReportingOverflow(digit)
            if shifted.overflow || added.overflow {
                return negative ? Int.min : Int.max
            }
            value = added.partialValue
            index += 1
        }
        return negative ? -value : value
    }
}
