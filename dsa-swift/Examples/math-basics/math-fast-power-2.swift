// Generated from src/dsa/content/lessons/math-basics/math-fast-power.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func power(_ x: Int, _ n: Int) -> Int {
    if n == 0 {
        return 1
    }
    let half = power(x, n / 2)
    return n % 2 == 0 ? half * half : half * half * x
}

print(power(3, 13), power(2, 10))
