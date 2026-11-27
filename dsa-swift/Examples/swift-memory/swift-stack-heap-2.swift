// Generated from src/dsa/content/lessons/swift-memory/swift-stack-heap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Counter {
    var count = 0
}

let first = Counter()
let second = first      // copies the reference, not the object
second.count += 1
print(first.count)
print(first === second)
