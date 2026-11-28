// Generated from src/dsa/content/lessons/swift-collections/swift-counting-grouping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let votes = ["tea", "coffee", "tea", "juice", "tea", "coffee"]
var counts: [String: Int] = [:]

for vote in votes {
    if let current = counts[vote] {
        counts[vote] = current + 1
    } else {
        counts[vote] = 1
    }
}

for drink in counts.keys.sorted() {
    print(drink, counts[drink] ?? 0)
}
