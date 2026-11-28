// Generated from src/dsa/content/lessons/complexity/bigo-notation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func steps(_ n: Int) -> Int {
    3 * n + 2
}

for n in [1, 2, 10, 100, 1_000] {
    let bound = 4 * n
    print("n = \(n): 3n + 2 = \(steps(n)), 4n = \(bound), within bound: \(steps(n) <= bound)")
}
