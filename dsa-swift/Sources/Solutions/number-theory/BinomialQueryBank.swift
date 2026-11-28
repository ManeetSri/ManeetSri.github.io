// Reference solution: A bank of binomial queries. Build factorials up to the largest n asked about,
// reducing modulo the prime 1,000,000,007. Fermat's little theorem gives the inverse of the last
// factorial as fact[N]^(p − 2), and walking down with invFact[i − 1] = invFact[i] · i fills in every
// other inverse factorial without another power. Then C(n, k) = fact[n] · invFact[k] · invFact[n − k],
// and k outside 0…n gives 0. O(N + log p + q) time for q queries, O(N) space.

public enum BinomialQueryBank {
    private static let mod = 1_000_000_007

    public static func answers(_ queries: [[Int]]) -> [Int] {
        let limit = queries.map { $0[0] }.max() ?? 0
        var fact = Array(repeating: 1, count: limit + 1)
        for i in stride(from: 1, through: limit, by: 1) {
            fact[i] = fact[i - 1] * i % mod
        }
        var invFact = Array(repeating: 1, count: limit + 1)
        invFact[limit] = power(fact[limit], mod - 2)
        for i in stride(from: limit, to: 0, by: -1) {
            invFact[i - 1] = invFact[i] * i % mod      // 1/(i − 1)! = i · 1/i!
        }
        return queries.map { query in
            let (n, k) = (query[0], query[1])
            guard k >= 0, k <= n else { return 0 }
            return fact[n] * invFact[k] % mod * invFact[n - k] % mod
        }
    }

    private static func power(_ base: Int, _ exponent: Int) -> Int {
        var result = 1
        var square = base % mod
        var e = exponent
        while e > 0 {
            if e & 1 == 1 { result = result * square % mod }
            square = square * square % mod
            e >>= 1
        }
        return result
    }
}
