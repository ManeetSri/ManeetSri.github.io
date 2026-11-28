// Reference solution: Kaprekar trace. Translates the pseudocode line by line. At most seven passes of
// four digits each, so O(1) time and space.

public enum KaprekarTrace {
    public static func trace(from start: Int) -> [Int] {
        var value = start
        var trace = [value]
        while value != 6174 && value != 0 {
            let digits = fourDigits(of: value).sorted()
            var small = 0
            var big = 0
            for digit in digits {
                small = small * 10 + digit
            }
            for digit in digits.reversed() {
                big = big * 10 + digit
            }
            value = big - small
            trace.append(value)
        }
        return trace
    }

    /// Exactly four digits, least significant first, so 999 gives [9, 9, 9, 0].
    private static func fourDigits(of number: Int) -> [Int] {
        var n = number
        var digits: [Int] = []
        for _ in 0..<4 {
            digits.append(n % 10)
            n /= 10
        }
        return digits
    }
}
