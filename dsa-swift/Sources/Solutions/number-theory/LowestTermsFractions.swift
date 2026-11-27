// Reference solution: Fractions in lowest terms. φ(n) counts the numerators 1…n coprime to n, and
// φ(n) = n · Π (1 − 1/p) over the distinct primes p dividing n: factorise by trial division up to √n,
// applying result -= result / p for each prime found, and once more for a prime left over above √n.
// O(√n) time. A fraction p/q with 0 < p < q is in lowest terms exactly when gcd(p, q) = 1, so the
// count for denominators up to N is φ(2) + … + φ(N). A totient sieve gives every φ at once: start with
// phi[i] = i, and for each prime p (an entry still equal to its index), apply phi[m] -= phi[m] / p to
// every multiple. O(N log log N) time, O(N) space. The sieve uses `while` loops: in a debug build, which
// is what `swift test` makes, they run about twice as fast as `for … in stride`.

public enum LowestTermsFractions {
    public static func phi(_ n: Int) -> Int {
        var rest = n
        var result = n
        var p = 2
        while p * p <= rest {
            if rest % p == 0 {
                while rest % p == 0 { rest /= p }
                result -= result / p
            }
            p += 1
        }
        if rest > 1 { result -= result / rest }        // one prime factor above √n
        return result
    }

    public static func count(maxDenominator n: Int) -> Int {
        guard n >= 2 else { return 0 }
        var phi = Array(0...n)
        var total = 0
        var i = 2
        while i <= n {
            if phi[i] == i {                            // untouched, so i is prime
                var multiple = i
                while multiple <= n {
                    phi[multiple] -= phi[multiple] / i
                    multiple += i
                }
            }
            total += phi[i]                             // every prime factor of i has been applied by now
            i += 1
        }
        return total
    }
}
