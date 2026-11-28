// Generated from src/dsa/content/lessons/swift-closures/swift-compactmap-flatmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let votes = ["tea", "coffee", "tea", "juice", "tea", "coffee"]

let counts = votes.reduce(into: [String: Int]()) { tally, vote in
    tally[vote, default: 0] += 1
}

for drink in counts.keys.sorted() {
    print(drink, counts[drink]!)
}
