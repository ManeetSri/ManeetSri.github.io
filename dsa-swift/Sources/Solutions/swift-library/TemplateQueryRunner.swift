// Reference solution: Range sums through the template. A byte scanner reads every integer straight
// from the buffer (skip separators, read an optional minus sign, accumulate digits), prefix sums turn
// each query into one subtraction, and the answers are collected in one String that's returned
// whole, the way the template prints once at the end. O(bytes + n + q) time, O(n) space for the
// prefix sums plus the output.

public enum TemplateQueryRunner {
    /// The template's reader, reading from a byte array
    struct Reader {
        private let bytes: [UInt8]
        private var position = 0

        init(_ bytes: [UInt8]) {
            self.bytes = bytes
        }

        mutating func int() -> Int {
            while position < bytes.count && bytes[position] <= 32 {
                position += 1
            }
            var isNegative = false
            if position < bytes.count && bytes[position] == UInt8(ascii: "-") {
                isNegative = true
                position += 1
            }
            var value = 0
            while position < bytes.count, bytes[position] >= 48, bytes[position] <= 57 {
                value = value * 10 + Int(bytes[position] - 48)
                position += 1
            }
            return isNegative ? -value : value
        }
    }

    public static func run(_ input: [UInt8]) -> String {
        var reader = Reader(input)
        let n = reader.int()
        let q = reader.int()
        // prefix[i] is the sum of the first i values, so values l...r (1-based) sum to prefix[r] - prefix[l - 1]
        var prefix = [0]
        prefix.reserveCapacity(n + 1)
        for _ in 0..<n {
            prefix.append(prefix[prefix.count - 1] + reader.int())
        }
        var output = ""
        for _ in 0..<q {
            let left = reader.int()
            let right = reader.int()
            output += String(prefix[right] - prefix[left - 1])
            output += "\n"
        }
        return output
    }
}
