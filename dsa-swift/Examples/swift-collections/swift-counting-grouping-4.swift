// Generated from src/dsa/content/lessons/swift-collections/swift-counting-grouping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let votes = ["tea", "coffee", "tea", "juice", "tea", "coffee"]
let counts = votes.reduce(into: [String: Int]()) { counts, vote in
    counts[vote, default: 0] += 1
}
print(counts["tea"] ?? 0, counts["coffee"] ?? 0)
