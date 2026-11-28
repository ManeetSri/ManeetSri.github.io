// Reference solution: Are these two slices equal? Prefix hashes and powers modulo the prime 2^61 - 1,
// with a base chosen at random when called: the hash of text[a..<b] is prefix[b] - prefix[a] · base^(b - a),
// so each query compares two hashes in O(1). The prime modulus (not wrapping UInt64 arithmetic, which is
// mod 2^64 and broken by Thue–Morse strings) and the random base make a wrong answer astronomically
// unlikely. O(n + q) time, O(n) space.

public enum SliceEqualityQueries {
    public static func answer(text: String, queries: [[Int]]) -> [Bool] {
        let s = Array(text.utf8)
        let modulus: UInt64 = (1 << 61) - 1
        func mulMod(_ x: UInt64, _ y: UInt64) -> UInt64 {
            let (high, low) = x.multipliedFullWidth(by: y)
            let sum = ((high << 3) | (low >> 61)) + (low & modulus)
            return sum >= modulus ? sum - modulus : sum
        }

        let base = UInt64.random(in: 256..<modulus)
        var prefix = [UInt64](repeating: 0, count: s.count + 1)
        var power = [UInt64](repeating: 1, count: s.count + 1)
        for i in s.indices {
            let value = mulMod(prefix[i], base) + UInt64(s[i])
            prefix[i + 1] = value >= modulus ? value - modulus : value
            power[i + 1] = mulMod(power[i], base)
        }
        func hash(_ from: Int, _ length: Int) -> UInt64 {
            let shifted = mulMod(prefix[from], power[length])
            let end = prefix[from + length]
            return end >= shifted ? end - shifted : end + modulus - shifted
        }

        return queries.map { query in
            hash(query[0], query[2]) == hash(query[1], query[2])
        }
    }
}
