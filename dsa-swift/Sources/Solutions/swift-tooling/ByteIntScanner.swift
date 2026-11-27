// Reference solution: A byte-level integer scanner. Skip whitespace bytes, read an optional "-", then build
// the number digit by digit with value * 10 + digit. Each byte is looked at once: O(n) time, and O(1) extra
// space for the reader (integers(in:) needs space for its result).

public enum ByteIntScanner {
    public struct Reader {
        private let bytes: [UInt8]
        private var position = 0

        public init(_ bytes: [UInt8]) {
            self.bytes = bytes
        }

        public mutating func nextInt() -> Int? {
            // Spaces, tabs, newlines and carriage returns all have codes of 32 or less
            while position < bytes.count && bytes[position] <= 32 {
                position += 1
            }
            guard position < bytes.count else { return nil }

            var isNegative = false
            if bytes[position] == UInt8(ascii: "-") {
                isNegative = true
                position += 1
            }
            var value = 0
            while position < bytes.count,
                  bytes[position] >= UInt8(ascii: "0"),
                  bytes[position] <= UInt8(ascii: "9") {
                value = value * 10 + Int(bytes[position] - UInt8(ascii: "0"))
                position += 1
            }
            return isNegative ? -value : value
        }
    }

    public static func integers(in bytes: [UInt8]) -> [Int] {
        var reader = Reader(bytes)
        var result: [Int] = []
        while let number = reader.nextInt() {
            result.append(number)
        }
        return result
    }
}
