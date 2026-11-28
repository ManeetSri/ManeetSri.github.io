// Generated from src/dsa/content/lessons/complexity/bigo-notation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func f(_ n: Int) -> Int {
    n * n + 10 * n
}

for n in [5, 10, 100, 1_000] {
    print("n = \(n): f(n) = \(f(n)), n² = \(n * n), 2n² = \(2 * n * n)")
}
