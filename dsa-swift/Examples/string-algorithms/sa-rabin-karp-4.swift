// Generated from src/dsa/content/lessons/string-algorithms/sa-rabin-karp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Thue–Morse: start with "a", then repeatedly append a copy with a and b swapped
var first: [UInt8] = [97]
for _ in 0..<11 {
    first += first.map { $0 == 97 ? UInt8(98) : UInt8(97) }
}
let second: [UInt8] = first.map { $0 == 97 ? 98 : 97 }   // the same string with a and b swapped
print("length:", first.count, "equal strings:", first == second)

// Tempting: let UInt64 wrap around, which is arithmetic mod 2^64
func wrappingHash(_ s: [UInt8], base: UInt64) -> UInt64 {
    var h: UInt64 = 0
    for c in s { h = h &* base &+ UInt64(c) }
    return h
}

let mersenne: UInt64 = (1 << 61) - 1
func mulMod(_ a: UInt64, _ b: UInt64) -> UInt64 {
    let (high, low) = a.multipliedFullWidth(by: b)
    let sum = ((high << 3) | (low >> 61)) + (low & mersenne)
    return sum >= mersenne ? sum - mersenne : sum
}
func primeHash(_ s: [UInt8], base: UInt64) -> UInt64 {
    var h: UInt64 = 0
    for c in s {
        h = mulMod(h, base) + UInt64(c)
        if h >= mersenne { h -= mersenne }
    }
    return h
}

for base: UInt64 in [131, 1_000_003, 911_382_323] {
    print("base \(base): mod 2^64 equal:", wrappingHash(first, base: base) == wrappingHash(second, base: base),
          "mod 2^61 - 1 equal:", primeHash(first, base: base) == primeHash(second, base: base))
}
