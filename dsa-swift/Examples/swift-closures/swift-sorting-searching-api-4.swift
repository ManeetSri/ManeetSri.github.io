// Generated from src/dsa/content/lessons/swift-closures/swift-sorting-searching-api.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = ["pear", "fig", "plum", "apple", "kiwi"]

let ranked = words.sorted { first, second in
    if first.count != second.count {
        return first.count > second.count     // longer words first
    }
    return first < second                     // then A to Z
}
print(ranked)
