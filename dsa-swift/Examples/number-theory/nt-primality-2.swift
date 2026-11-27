// Generated from src/dsa/content/lessons/number-theory/nt-primality.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func modPow(_ base: Int, _ exponent: Int, _ m: Int) -> Int {
    var result = 1 % m
    var square = base % m
    var e = exponent
    while e > 0 {
        if e % 2 == 1 { result = result * square % m }
        square = square * square % m
        e /= 2
    }
    return result
}

// The squaring chain a^d, a^(2d), …, a^(n-1) for n - 1 = d · 2^s
func chain(_ a: Int, _ n: Int) -> [Int] {
    var d = n - 1
    var s = 0
    while d % 2 == 0 { d /= 2; s += 1 }
    var x = modPow(a, d, n)
    var values = [x]
    for _ in 0..<s {
        x = x * x % n
        values.append(x)
    }
    return values
}

print(chain(2, 561))      // 561 - 1 = 35 · 2^4
print(chain(2, 569))      // 569 is prime: 568 = 71 · 2^3
print(chain(5, 569))
print(chain(2, 2047))     // 2047 = 23 × 89 fools base 2
print(chain(3, 2047))
