// Generated from src/dsa/content/lessons/swift-collections/swift-counting-grouping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let votes = ["tea", "coffee", "tea", "juice", "tea", "coffee", "juice"]
var counts: [String: Int] = [:]
for vote in votes {
    counts[vote, default: 0] += 1
}

let ranked = counts.sorted { a, b in
    if a.value != b.value {
        return a.value > b.value
    }
    return a.key < b.key
}
for (drink, count) in ranked {
    print(drink, count)
}
