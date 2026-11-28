// Generated from src/dsa/content/lessons/complexity/bigo-notation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Whatever constant c you pick, n² eventually passes c × n
for c in [10, 100, 1_000] {
    var n = 1
    while n * n <= c * n {
        n += 1
    }
    print("c = \(c): n² beats \(c)n from n = \(n)")
}
