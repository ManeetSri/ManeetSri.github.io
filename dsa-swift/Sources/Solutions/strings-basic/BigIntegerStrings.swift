// Reference solution: Signed big integers as strings. Each number becomes a sign and an array of
// digits, least significant first, so index i is the 10^i place. Addition with equal signs adds the
// magnitudes with a carry; with different signs it subtracts the smaller magnitude from the larger
// with a borrow, and takes the larger one's sign. Multiplication adds digit products into place
// i + j, then sweeps the carries once. O(m + n) to add, O(m · n) to multiply.

public enum BigIntegerStrings {
    public static func add(_ a: String, _ b: String) -> String {
        let x = parse(a)
        let y = parse(b)
        if x.negative == y.negative {
            return format(negative: x.negative, digits: addMagnitudes(x.digits, y.digits))
        }
        switch compareMagnitudes(x.digits, y.digits) {
        case 0:
            return "0"
        case 1:
            return format(negative: x.negative, digits: subtractMagnitudes(x.digits, y.digits))
        default:
            return format(negative: y.negative, digits: subtractMagnitudes(y.digits, x.digits))
        }
    }

    public static func multiply(_ a: String, _ b: String) -> String {
        let x = parse(a)
        let y = parse(b)
        var product = [Int](repeating: 0, count: x.digits.count + y.digits.count)
        for i in x.digits.indices {
            for j in y.digits.indices {
                product[i + j] += x.digits[i] * y.digits[j]
            }
        }
        var carry = 0
        for place in product.indices {
            let total = product[place] + carry
            product[place] = total % 10
            carry = total / 10
        }
        return format(negative: x.negative != y.negative, digits: product)
    }

    // "-907" becomes (true, [7, 0, 9])
    private static func parse(_ text: String) -> (negative: Bool, digits: [Int]) {
        let bytes = Array(text.utf8)
        let negative = bytes.first == UInt8(ascii: "-")
        let digits = bytes.dropFirst(negative ? 1 : 0).reversed().map { Int($0 - UInt8(ascii: "0")) }
        return (negative, digits)
    }

    private static func addMagnitudes(_ x: [Int], _ y: [Int]) -> [Int] {
        var result: [Int] = []
        var carry = 0
        for place in 0..<max(x.count, y.count) {
            let total = (place < x.count ? x[place] : 0) + (place < y.count ? y[place] : 0) + carry
            result.append(total % 10)
            carry = total / 10
        }
        if carry > 0 {
            result.append(carry)
        }
        return result
    }

    // Requires x ≥ y
    private static func subtractMagnitudes(_ x: [Int], _ y: [Int]) -> [Int] {
        var result: [Int] = []
        var borrow = 0
        for place in 0..<x.count {
            var digit = x[place] - borrow - (place < y.count ? y[place] : 0)
            borrow = 0
            if digit < 0 {
                digit += 10
                borrow = 1
            }
            result.append(digit)
        }
        return result
    }

    // 1 if x > y, -1 if x < y, 0 if equal. Neither has leading zeros.
    private static func compareMagnitudes(_ x: [Int], _ y: [Int]) -> Int {
        if x.count != y.count {
            return x.count > y.count ? 1 : -1
        }
        for place in stride(from: x.count - 1, through: 0, by: -1) where x[place] != y[place] {
            return x[place] > y[place] ? 1 : -1
        }
        return 0
    }

    // Drops leading zeros and never writes "-0"
    private static func format(negative: Bool, digits: [Int]) -> String {
        var digits = digits
        while digits.count > 1 && digits.last == 0 {
            digits.removeLast()
        }
        let isZero = digits == [0]
        let body = digits.reversed().map { String($0) }.joined()
        return (negative && !isZero ? "-" : "") + body
    }
}
