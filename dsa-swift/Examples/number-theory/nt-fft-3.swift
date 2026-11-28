// Generated from src/dsa/content/lessons/number-theory/nt-fft.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let mod = 998_244_353          // 119 · 2²³ + 1, with primitive root 3

func power(_ base: Int, _ exponent: Int) -> Int {
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

let n = 8
let w = power(3, (mod - 1) / n)                     // a primitive 8th root of unity modulo the prime
print(w)
print((0...8).map { power(w, $0) })
print((0...4).map { power(w, 2 * $0) } == (0...4).map { power(power(3, (mod - 1) / 4), $0) })
print(power(w, 4), mod - 1)
