// Reference solution: Prime factor pairs. Trial division: for d = 2, 3, … while d * d <= the
// remaining value, divide d out completely and record its exponent; anything above 1 left at the
// end is a prime. The divisor count is the product of (exponent + 1). O(√n) time.

public enum PrimeFactorPairs {
    public static func factorise(_ n: Int) -> [(prime: Int, exponent: Int)] {
        var rest = n
        var factors: [(prime: Int, exponent: Int)] = []
        var d = 2
        while d * d <= rest {
            if rest % d == 0 {
                var exponent = 0
                while rest % d == 0 {
                    rest /= d
                    exponent += 1
                }
                factors.append((prime: d, exponent: exponent))
            }
            d += 1
        }
        if rest > 1 {
            factors.append((prime: rest, exponent: 1))
        }
        return factors
    }

    public static func divisorCount(of n: Int) -> Int {
        factorise(n).reduce(1) { count, factor in count * (factor.exponent + 1) }
    }
}
