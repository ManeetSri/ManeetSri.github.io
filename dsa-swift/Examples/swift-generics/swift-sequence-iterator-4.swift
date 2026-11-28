// Generated from src/dsa/content/lessons/swift-generics/swift-sequence-iterator.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct CountdownIterator: IteratorProtocol {
    var current: Int
    mutating func next() -> Int? {
        guard current > 0 else { return nil }
        defer { current -= 1 }
        return current
    }
}

struct Countdown: Sequence {
    let start: Int
    func makeIterator() -> CountdownIterator {
        CountdownIterator(current: start)
    }
}

let launch = Countdown(start: 5)
print(Array(launch))
print(launch.map { $0 * 10 })
print(launch.filter { $0.isMultiple(of: 2) })
print(launch.reduce(0, +))
print(launch.contains(3), launch.max() ?? 0)
for (index, value) in launch.enumerated() where index < 2 {
    print(index, value)
}
