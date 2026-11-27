// Generated from src/dsa/content/lessons/number-theory/nt-ncr-mod-p.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// C(n, k) mod a small prime p, by Lucas' theorem: multiply C(nᵢ, kᵢ) over the base-p digits
func lucas(_ n: Int, _ k: Int, _ p: Int) -> Int {
    // Pascal's triangle mod p for digits 0…p-1: tiny, because p is small
    var table = Array(repeating: Array(repeating: 0, count: p), count: p)
    for i in 0..<p {
        table[i][0] = 1
        for j in stride(from: 1, through: i, by: 1) {
            table[i][j] = (table[i - 1][j - 1] + table[i - 1][j]) % p
        }
    }
    var result = 1
    var n = n
    var k = k
    while n > 0 || k > 0 {
        let (ni, ki) = (n % p, k % p)       // the lowest base-p digits
        if ki > ni { return 0 }              // C(nᵢ, kᵢ) = 0 makes the whole product 0
        result = result * table[ni][ki] % p
        n /= p
        k /= p
    }
    return result
}

// Check against Pascal's triangle mod p for every n, k up to 60
var ok = true
for p in [2, 3, 5, 7, 13] {
    var row = [1]
    for n in 0...60 {
        for k in 0...n where lucas(n, k, p) != row[k] { ok = false }
        row = [1] + (1..<row.count).map { (row[$0 - 1] + row[$0]) % p } + [1]
    }
}
print(ok)
print(lucas(10, 3, 3), lucas(10, 3, 7), 120 % 7)
print(lucas(1_000_000_000_000_000_000, 999_999_999, 1009))
print(lucas(123_456_789_012_345_678, 9_876_543_210, 1009))
var odd = 0
for k in 0...100 where lucas(100, k, 2) == 1 { odd += 1 }
print(odd, (0...100).filter { $0 & 100 == $0 }.count)
