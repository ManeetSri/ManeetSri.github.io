// Reference solution: Powers with a thousand-digit exponent. Fast power from the top, in base 10:
// if the digits read so far form the exponent e, appending a digit d makes it 10e + d, and
// x^(10e + d) = (x^e)^10 · x^d. So one pass over the digits keeps result = x^(digits so far) mod m,
// with a small fast power for each ^10 and ^d. Every product is of two values below m, so with
// m ≤ 2,000,000,000 nothing overflows. O(L) multiplications for L digits, O(1) extra space.

public enum DigitExponentPower {
    public static func remainder(base: Int, exponentDigits: [Int], modulus: Int) -> Int {
        let x = ((base % modulus) + modulus) % modulus       // reduce first, and fix negative bases
        var result = 1 % modulus                             // 1 % m handles m = 1
        for digit in exponentDigits {
            result = power(result, 10, modulus) * power(x, digit, modulus) % modulus
        }
        return result
    }

    /// value^exponent mod m for a small exponent, by repeated squaring
    private static func power(_ value: Int, _ exponent: Int, _ modulus: Int) -> Int {
        var result = 1 % modulus
        var square = value
        var remaining = exponent
        while remaining > 0 {
            if remaining % 2 == 1 {
                result = result * square % modulus
            }
            square = square * square % modulus
            remaining /= 2
        }
        return result
    }
}
