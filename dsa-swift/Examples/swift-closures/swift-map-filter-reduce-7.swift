// Generated from src/dsa/content/lessons/swift-closures/swift-map-filter-reduce.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = ["Swift", "is", "fun"]

let totalLetters = words.reduce(0) { $0 + $1.count }
print(totalLetters)

let longest = words.reduce("") { best, word in
    word.count > best.count ? word : best
}
print(longest)
