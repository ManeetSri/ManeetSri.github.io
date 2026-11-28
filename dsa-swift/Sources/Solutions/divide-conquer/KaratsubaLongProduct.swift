// Reference solution: Multiply long numbers by splitting. Numbers are stored as limbs of four decimal
// digits (base 10,000), least significant first, so there are a quarter as many pieces as digits.
// Karatsuba splits both numbers at m limbs, x = x1·B^m + x0, and needs only three products:
// high = x1·y1, low = x0·y0 and both = (x1 + x0)(y1 + y0); the middle term x1·y0 + x0·y1 is
// both - high - low. The three are added into one array, the subtractions leave some limbs negative for
// a moment, and a single carry pass puts every limb back in 0..<10,000. Below a cutoff it multiplies
// schoolbook-style, which is faster for short numbers. T(n) = 3T(n/2) + O(n): O(n^1.585) time.

public enum KaratsubaLongProduct {
    private static let base = 10_000              // each limb holds four decimal digits
    private static let cutoff = 24

    public static func multiply(_ a: String, _ b: String) -> String {
        let product = karatsuba(limbs(a), limbs(b))
        var text = String(product.last!)
        for limb in product.dropLast().reversed() {
            let digits = String(limb)
            text += String(repeating: "0", count: 4 - digits.count) + digits
        }
        return text
    }

    private static func limbs(_ text: String) -> [Int] {
        let digits = Array(text.utf8).map { Int($0) - 48 }
        var result: [Int] = []
        var end = digits.count
        while end > 0 {
            let start = max(0, end - 4)
            var limb = 0
            for index in start..<end {
                limb = limb * 10 + digits[index]
            }
            result.append(limb)
            end = start
        }
        return trimmed(result)
    }

    private static func karatsuba(_ a: [Int], _ b: [Int]) -> [Int] {
        if a.count <= cutoff || b.count <= cutoff {
            return schoolbook(a, b)
        }
        let m = max(a.count, b.count) / 2
        let a0 = trimmed(Array(a.prefix(m))), a1 = a.count > m ? Array(a.dropFirst(m)) : [0]
        let b0 = trimmed(Array(b.prefix(m))), b1 = b.count > m ? Array(b.dropFirst(m)) : [0]
        let high = karatsuba(a1, b1)
        let low = karatsuba(a0, b0)
        let both = karatsuba(add(a1, a0), add(b1, b0))
        var result = Array(repeating: 0, count: max(both.count + m, high.count + 2 * m, low.count) + 1)
        // low + (both - high - low)·B^m + high·B^(2m), limb by limb; the carry pass tidies up
        for (index, limb) in low.enumerated() {
            result[index] += limb
            result[index + m] -= limb
        }
        for (index, limb) in high.enumerated() {
            result[index + 2 * m] += limb
            result[index + m] -= limb
        }
        for (index, limb) in both.enumerated() {
            result[index + m] += limb
        }
        return normalised(result)
    }

    /// Each limb product is below 10^8, and one side has at most `cutoff` limbs, so no cell overflows
    private static func schoolbook(_ a: [Int], _ b: [Int]) -> [Int] {
        var result = Array(repeating: 0, count: a.count + b.count)
        for i in a.indices where a[i] != 0 {
            for j in b.indices {
                result[i + j] += a[i] * b[j]
            }
        }
        return normalised(result)
    }

    private static func add(_ a: [Int], _ b: [Int]) -> [Int] {
        var result = Array(repeating: 0, count: max(a.count, b.count) + 1)
        for (index, limb) in a.enumerated() {
            result[index] += limb
        }
        for (index, limb) in b.enumerated() {
            result[index] += limb
        }
        return normalised(result)
    }

    /// Carries every limb into 0..<base, borrowing where a limb is negative
    private static func normalised(_ number: [Int]) -> [Int] {
        var result = number
        var carry = 0
        for index in result.indices {
            var total = result[index] + carry
            carry = total / base
            total %= base
            if total < 0 {                          // a limb left negative by the subtraction
                total += base
                carry -= 1
            }
            result[index] = total
        }
        return trimmed(result)
    }

    private static func trimmed(_ number: [Int]) -> [Int] {
        var number = number
        while number.count > 1 && number.last == 0 {
            number.removeLast()
        }
        return number.isEmpty ? [0] : number
    }
}
