// Reference solution: Primes up to n. The Sieve of Eratosthenes: for each p still marked prime,
// cross out p * p, p * p + p, … up to n, stopping once p * p passes n.
// O(n log log n) time, O(n) space.

public enum PrimeSieve {
    public static func primes(upTo n: Int) -> [Int] {
        guard n >= 2 else { return [] }
        var isPrime = Array(repeating: true, count: n + 1)
        isPrime[0] = false
        isPrime[1] = false
        var p = 2
        while p * p <= n {
            if isPrime[p] {
                for multiple in stride(from: p * p, through: n, by: p) {
                    isPrime[multiple] = false
                }
            }
            p += 1
        }
        return isPrime.indices.filter { isPrime[$0] }
    }
}
