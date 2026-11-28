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

// Powers of 3 modulo 7 cycle back to 1 after p - 1 = 6 steps
print((1...6).map { modPow(3, $0, 7) })
print((1...6).map { modPow(2, $0, 7) })
print((1..<7).map { modPow($0, 6, 7) })
