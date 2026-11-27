// Generated from src/dsa/content/lessons/math-basics/math-fast-power.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func slowPower(_ base: Int, _ exponent: Int) -> Int {
    var result = 1
    for _ in 0..<exponent {
        result *= base
    }
    return result
}

print(slowPower(3, 4), slowPower(2, 10), slowPower(7, 0))
