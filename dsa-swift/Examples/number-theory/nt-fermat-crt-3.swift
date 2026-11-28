// Generated from src/dsa/content/lessons/number-theory/nt-fermat-crt.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func modPow(_ base: Int, _ exponent: Int, _ m: Int) -> Int {
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

let p = 1_000_000_007
let e = modPow(10, 100, p - 1)          // 10¹⁰⁰ reduced modulo p - 1
print(e, modPow(3, e, p))

// On an exponent that does fit, both routes agree
print(modPow(3, 1_000_000_000_000_000_000, p), modPow(3, 1_000_000_000_000_000_000 % (p - 1), p))
