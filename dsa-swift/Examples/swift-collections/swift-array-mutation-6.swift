// Generated from src/dsa/content/lessons/swift-collections/swift-array-mutation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var history = ["home", "search"]
while let page = history.popLast() {
    print("Back from \(page)")
}
print(history.popLast() ?? "nothing left")
