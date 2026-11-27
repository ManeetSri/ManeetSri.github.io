// Generated from src/dsa/content/lessons/swift-closures/swift-closure-syntax.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = ["banana", "fig", "cherry", "kiwi"]

let byLength = words.sorted { first, second in
    if first.count != second.count {
        return first.count < second.count
    }
    return first < second
}
print(byLength)
