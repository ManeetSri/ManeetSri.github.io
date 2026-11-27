// Generated from src/dsa/content/lessons/string-algorithms/sa-rabin-karp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mersenne: UInt64 = (1 << 61) - 1               // 2^61 − 1, a prime

// a × b mod 2^61 − 1, for a and b below the modulus, with no overflow
func mulMod(_ a: UInt64, _ b: UInt64) -> UInt64 {
    let (high, low) = a.multipliedFullWidth(by: b)  // the exact product is high · 2^64 + low
    let top = (high << 3) | (low >> 61)             // the product's bits from 61 up
    let bottom = low & mersenne                     // its lowest 61 bits
    let sum = top + bottom                          // 2^61 ≡ 1, so product ≡ top + bottom
    return sum >= mersenne ? sum - mersenne : sum
}

// The same answer the slow, obviously right way: a 128-bit division
func slowMulMod(_ a: UInt64, _ b: UInt64) -> UInt64 {
    mersenne.dividingFullWidth(a.multipliedFullWidth(by: b)).remainder
}

let values: [UInt64] = [0, 1, 2, 131, 1_000_000_007, mersenne - 2, mersenne - 1]
var agree = 0
for a in values {
    for b in values where mulMod(a, b) == slowMulMod(a, b) {
        agree += 1
    }
}
print("agree on \(agree) of \(values.count * values.count) pairs")
print(mulMod(mersenne - 1, mersenne - 1))           // (−1) × (−1) = 1
print(mulMod(123_456_789_012, 987_654_321_098))
