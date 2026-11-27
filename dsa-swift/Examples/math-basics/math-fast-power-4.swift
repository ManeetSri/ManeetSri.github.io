// Generated from src/dsa/content/lessons/math-basics/math-fast-power.mdx. Edit the lesson, then run
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

print(modPow(2, 1_000_000_000_000_000_000, 1_000_000_007))
print(modPow(3, 200, 1000))
print(modPow(-2, 3, 5))
print(modPow(10, 0, 1))
