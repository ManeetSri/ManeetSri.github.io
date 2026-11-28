// Generated from src/dsa/content/lessons/swift-memory/swift-retain-cycles.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Counter {
    var count = 0
    var onTap: (() -> Void)?

    init() { print("Counter created") }
    deinit { print("Counter freed") }

    func setUp() {
        onTap = { self.count += 1 }
    }
}

do {
    let counter = Counter()
    counter.setUp()
    counter.onTap?()
    print(counter.count)
}
print("done")
