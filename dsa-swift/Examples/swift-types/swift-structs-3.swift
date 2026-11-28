// Generated from src/dsa/content/lessons/swift-types/swift-structs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Counter {
    var count = 0
}

var clicks = Counter()
clicks.count += 1
clicks.count += 1
print(clicks.count)
