// Generated from src/dsa/content/lessons/swift-generics/swift-sequence-iterator.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct CountdownIterator: IteratorProtocol {
    var current: Int

    mutating func next() -> Int? {
        guard current > 0 else {
            return nil
        }
        defer { current -= 1 }
        return current
    }
}

var countdown = CountdownIterator(current: 3)
print(countdown.next() ?? 0)
print(countdown.next() ?? 0)
print(countdown.next() ?? 0)
print(countdown.next() == nil)
