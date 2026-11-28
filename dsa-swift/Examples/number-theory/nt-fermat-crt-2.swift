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

print((1..<7).map { modPow($0, 5, 7) })
let p = 1_000_000_007
print(modPow(2, p - 2, p), 2 * modPow(2, p - 2, p) % p)
print(modPow(4, 3, 5), 12 * modPow(4, 3, 5) % 5)
