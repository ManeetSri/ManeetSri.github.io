// Generated from src/dsa/content/lessons/complexity/bigo-rules.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

for n in [10, 100, 1_000, 10_000] {
    let total = n * n + 100 * n + 5_000
    let share = n * n * 100 / total
    print("n = \(n): total \(total), n² is \(share)% of it")
}
