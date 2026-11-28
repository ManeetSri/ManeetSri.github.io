// Generated from src/dsa/content/lessons/math-basics/math-series-logs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func triangle(_ n: Int) -> Int {
    n % 2 == 0 ? (n / 2) * (n + 1) : n * ((n + 1) / 2)
}

print(triangle(100))
print(triangle(4_000_000_000))
