// Generated from src/dsa/content/lessons/math-basics/math-fast-power.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func power(_ base: Int, _ exponent: Int) -> Int {
    var result = 1
    var square = base
    var e = exponent
    while e > 0 {
        if e % 2 == 1 {
            result *= square
        }
        e /= 2
        if e > 0 {
            square *= square
        }
    }
    return result
}

print(power(3, 13), power(2, 62), power(-2, 5))
