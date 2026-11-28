// Generated from src/dsa/content/lessons/swift-optionals/swift-nil-coalescing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let votes = ["tea", "coffee", "tea", "water", "tea", "coffee"]
var counts: [String: Int] = [:]

for vote in votes {
    counts[vote] = (counts[vote] ?? 0) + 1
}

for (drink, count) in counts.sorted(by: <) {
    print("\(drink): \(count)")
}
