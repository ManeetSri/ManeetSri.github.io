// Reference solution: Huge powers, small remainders. Binary exponentiation: square the base
// repeatedly and multiply the squares for the exponent's 1 bits into the result, reducing modulo m
// after every multiplication. Reducing the base first fixes negatives and keeps every value
// below m, so products stay below 4 × 10¹⁸. O(log exponent) time, O(1) space.

public enum ModularPower {
    public static func power(_ base: Int, _ exponent: Int, modulo m: Int) -> Int {
        var result = 1 % m
        var square = ((base % m) + m) % m
        var e = exponent
        while e > 0 {
            if e % 2 == 1 {
                result = result * square % m
            }
            square = square * square % m
            e /= 2
        }
        return result
    }
}
