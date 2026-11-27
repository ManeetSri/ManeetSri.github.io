// Generated from src/dsa/content/lessons/arrays/arrays-sub-definitions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

for n in [3, 10, 20, 50] {
    let subarrays = n * (n + 1) / 2
    let subsequences = 1 << n         // 2ⁿ
    print("n = \(n): \(subarrays) subarrays, \(subsequences) subsequences")
}
